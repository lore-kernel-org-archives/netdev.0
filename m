From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 04/08] ipg: remove jumbo frame #ifdef from mtu
Date: Mon, 23 Jun 2008 14:35:37 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806231435170.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, Bircoph@list.ru,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbYFWLfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:35:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

Remove JUMBO_FRAME #ifdef from dev->mtu setting in ipg_nic_open() so that we
can make IPG_TXFRAG_SIZE configurable.

Tested-by: Andrew Savchenko <Bircoph@list.ru>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |    6 +++---
 drivers/net/ipg.h |    2 ++
 2 files changed, 5 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -1807,9 +1807,9 @@ static int ipg_nic_open(struct net_devic
 	sp->jumbo.found_start = 0;
 	sp->jumbo.current_size = 0;
 	sp->jumbo.skb = NULL;
-#ifdef JUMBO_FRAME
-	dev->mtu = IPG_TXFRAG_SIZE;
-#endif
+
+	if (IPG_TXFRAG_SIZE)
+		dev->mtu = IPG_TXFRAG_SIZE;
 
 	/* Enable transmit and receive operation of the IPG. */
 	ipg_w32((ipg_r32(MAC_CTRL) | IPG_MC_RX_ENABLE | IPG_MC_TX_ENABLE) &
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -598,6 +598,8 @@ enum ipg_regs {
 #ifdef JUMBO_FRAME
 /* IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash */
 #define		IPG_TXFRAG_SIZE		JUMBO_FRAME_SIZE
+#else
+#define		IPG_TXFRAG_SIZE		0 /* use default MTU */
 #endif
 
 /* Size of allocated received buffers. Nominally 0x0600.
