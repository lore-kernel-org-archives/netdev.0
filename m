From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 07/17] net: emulex-benet calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:27:47 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260923010.21024@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f73.google.com ([209.85.212.73]:63662 "EHLO
	mail-vb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932317Ab3KZR1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:27:48 -0500
Received: by mail-vb0-f73.google.com with SMTP id m10so632915vbh.0
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:27:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 741d3bf..4678858 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1581,7 +1581,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
 	skb->protocol = eth_type_trans(skb, netdev);
 	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = rxcp->rss_hash;
+		skb_set_rxhash(skb, rxcp->rss_hash, RXHASH_TYPE_L3);
 	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
@@ -1639,7 +1639,7 @@ static void be_rx_compl_process_gro(struct be_rx_obj *rxo,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (adapter->netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = rxcp->rss_hash;
+		skb_set_rxhash(skb, rxcp->rss_hash, RXHASH_TYPE_L3);
 	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
-- 
1.8.4.1
