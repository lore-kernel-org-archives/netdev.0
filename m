From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/11][TG3]: Eliminate the TG3_FLAG_GOT_SERDES_FLOWCTL
 flag.
Date: Fri, 04 May 2007 17:54:01 -0700
Message-ID: <1178326441.4859.22.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3359 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767925AbXEEAGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:06:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Eliminate the TG3_FLAG_GOT_SERDES_FLOWCTL flag.

This flag does not do anything useful.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6094d6b..84fc498 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2595,10 +2595,8 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 {
 	int current_link_up = 0;
 
- 	if (!(mac_status & MAC_STATUS_PCS_SYNCED)) {
-		tp->tg3_flags &= ~TG3_FLAG_GOT_SERDES_FLOWCTL;
+ 	if (!(mac_status & MAC_STATUS_PCS_SYNCED))
 		goto out;
-	}
 
 	if (tp->link_config.autoneg == AUTONEG_ENABLE) {
 		u32 flags;
@@ -2616,7 +2614,6 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
 
-			tp->tg3_flags |= TG3_FLAG_GOT_SERDES_FLOWCTL;
 			current_link_up = 1;
 		}
 		for (i = 0; i < 30; i++) {
@@ -2639,7 +2636,6 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 	} else {
 		/* Forcing 1000FD link up. */
 		current_link_up = 1;
-		tp->tg3_flags |= TG3_FLAG_GOT_SERDES_FLOWCTL;
 
 		tw32_f(MAC_MODE, (tp->mac_mode | MAC_MODE_SEND_CONFIGS));
 		udelay(40);
@@ -7400,9 +7396,7 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 	tg3_free_rings(tp);
-	tp->tg3_flags &=
-		~(TG3_FLAG_INIT_COMPLETE |
-		  TG3_FLAG_GOT_SERDES_FLOWCTL);
+	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
 
 	tg3_full_unlock(tp);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f76e310..dd04a46 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2222,7 +2222,6 @@ struct tg3 {
 #define TG3_FLAG_IN_RESET_TASK		0x04000000
 #define TG3_FLAG_40BIT_DMA_BUG		0x08000000
 #define TG3_FLAG_BROKEN_CHECKSUMS	0x10000000
-#define TG3_FLAG_GOT_SERDES_FLOWCTL	0x20000000
 #define TG3_FLAG_CHIP_RESETTING		0x40000000
 #define TG3_FLAG_INIT_COMPLETE		0x80000000
 	u32				tg3_flags2;


