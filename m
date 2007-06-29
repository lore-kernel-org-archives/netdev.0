From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 16/21] r8169: add bit description for the TxPoll register
Date: Fri, 29 Jun 2007 22:27:25 +0200
Message-ID: <20070629202725.GR3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46087 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753965AbXF2U2Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:28:25 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5d9e754..d8862cd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -250,6 +250,11 @@ enum rtl_register_content {
 	CmdTxEnb	= 0x04,
 	RxBufEmpty	= 0x01,
 
+	/* TXPoll register p.5 */
+	HPQ		= 0x80,		/* Poll cmd on the high prio queue */
+	NPQ		= 0x40,		/* Poll cmd on the low prio queue */
+	FSWInt		= 0x01,		/* Forced software interrupt */
+
 	/* Cfg9346Bits */
 	Cfg9346_Lock	= 0x00,
 	Cfg9346_Unlock	= 0xc0,
@@ -2405,7 +2410,7 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	smp_wmb();
 
-	RTL_W8(TxPoll, 0x40);	/* set polling bit */
+	RTL_W8(TxPoll, NPQ);	/* set polling bit */
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-- 
1.4.4.2

