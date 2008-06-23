From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 01/08] ipg: fix jumbo frame compilation
Date: Mon, 23 Jun 2008 14:34:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806231434050.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, Bircoph@list.ru,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632AbYFWLeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:34:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

Make jumbo frame support compile again. It was broken by the cleanup series
before the merge because the code is hidden under JUMBO_FRAME #ifdef.

Tested-by: Andrew Savchenko <Bircoph@list.ru>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -1271,7 +1271,7 @@ static void ipg_nic_rx_with_end(struct n
 
 			framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 
-			endframeLen = framelen - jumbo->current_size;
+			endframelen = framelen - jumbo->current_size;
 			/*
 			if (framelen > IPG_RXFRAG_SIZE)
 				framelen=IPG_RXFRAG_SIZE;
@@ -1279,8 +1279,8 @@ static void ipg_nic_rx_with_end(struct n
 			if (framelen > IPG_RXSUPPORT_SIZE)
 				dev_kfree_skb_irq(jumbo->skb);
 			else {
-				memcpy(skb_put(jumbo->skb, endframeLen),
-				       skb->data, endframeLen);
+				memcpy(skb_put(jumbo->skb, endframelen),
+				       skb->data, endframelen);
 
 				jumbo->skb->protocol =
 				    eth_type_trans(jumbo->skb, dev);
@@ -1352,16 +1352,16 @@ static int ipg_nic_rx(struct net_device 
 
 		switch (ipg_nic_rx_check_frame_type(dev)) {
 		case FRAME_WITH_START_WITH_END:
-			ipg_nic_rx_with_start_and_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_start_and_end(dev, sp, rxfd, entry);
 			break;
 		case FRAME_WITH_START:
-			ipg_nic_rx_with_start(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_start(dev, sp, rxfd, entry);
 			break;
 		case FRAME_WITH_END:
-			ipg_nic_rx_with_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_end(dev, sp, rxfd, entry);
 			break;
 		case FRAME_NO_START_NO_END:
-			ipg_nic_rx_no_start_no_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_no_start_no_end(dev, sp, rxfd, entry);
 			break;
 		}
 	}
