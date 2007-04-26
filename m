From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 10/12] r8169: add bit description for the TxPoll register
Date: Thu, 26 Apr 2007 23:49:15 +0200
Message-ID: <20070426214915.GK7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58562 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755157AbXDZVvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:51:54 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e6dbfc9..2cbb63b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -251,7 +251,9 @@ enum rtl_register_content {
 	RxBufEmpty	= 0x01,
 
 	/* TXPoll register p.5 */
-	FSWInt		= 1,		/* Forced software interrupt */
+	HPQ		= 0x80,		/* Poll cmd on the high prio queue */
+	NPQ		= 0x40,		/* Poll cmd on the low prio queue */
+	FSWInt		= 0x01,		/* Forced software interrupt */
 
 	/* Cfg9346Bits */
 	Cfg9346_Lock	= 0x00,
@@ -2519,7 +2521,7 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	smp_wmb();
 
-	RTL_W8(TxPoll, 0x40);	/* set polling bit */
+	RTL_W8(TxPoll, NPQ);	/* set polling bit */
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-- 
1.4.4.2
