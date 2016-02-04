From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169:   Prevent nic to start xmit without default priority.
Date: Thu,  4 Feb 2016 08:09:44 +0200
Message-ID: <1454566184-2298-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-225-121.residential.rdsnet.ro ([5.14.225.121]:34800 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123AbcBDGKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 01:10:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set default priority before xmit operations and, also when nic running
 on worst speed (500Mbs-1Mbs), this patch increase speed to 8-10Mbs.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7588ba7..30eed0d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7113,6 +7113,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	u32 opts[2];
 	int frags;
 
+	RTL_W8(TxPoll, NPQ);
+
 	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
 		goto err_stop_0;
@@ -7166,7 +7168,6 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	tp->cur_tx += frags + 1;
 
-	RTL_W8(TxPoll, NPQ);
 
 	mmiowb();
 
-- 
2.5.0
