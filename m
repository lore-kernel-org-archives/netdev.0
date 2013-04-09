From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 05/11] tg3: Add tg3_clear_mac_status() common
 function
Date: Tue, 9 Apr 2013 11:48:05 -0700
Message-ID: <1365533291-5672-6-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2275 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934348Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

Refactor for use in the next patch that adds sgmii phy support.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 30 ++++++++++++++----------------
 1 file changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a744998..568dd07 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4428,6 +4428,18 @@ static bool tg3_test_and_report_link_chg(struct tg3 *tp, int curr_link_up)
 	return false;
 }
 
+static void tg3_clear_mac_status(struct tg3 *tp)
+{
+	tw32(MAC_EVENT, 0);
+
+	tw32_f(MAC_STATUS,
+	       MAC_STATUS_SYNC_CHANGED |
+	       MAC_STATUS_CFG_CHANGED |
+	       MAC_STATUS_MI_COMPLETION |
+	       MAC_STATUS_LNKSTATE_CHANGED);
+	udelay(40);
+}
+
 static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 {
 	int current_link_up;
@@ -4437,14 +4449,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 	u8 current_duplex;
 	int i, err;
 
-	tw32(MAC_EVENT, 0);
-
-	tw32_f(MAC_STATUS,
-	     (MAC_STATUS_SYNC_CHANGED |
-	      MAC_STATUS_CFG_CHANGED |
-	      MAC_STATUS_MI_COMPLETION |
-	      MAC_STATUS_LNKSTATE_CHANGED));
-	udelay(40);
+	tg3_clear_mac_status(tp);
 
 	if ((tp->mi_mode & MAC_MI_MODE_AUTO_POLL) != 0) {
 		tw32_f(MAC_MI_MODE,
@@ -5470,14 +5475,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	tw32_f(MAC_MODE, tp->mac_mode);
 	udelay(40);
 
-	tw32(MAC_EVENT, 0);
-
-	tw32_f(MAC_STATUS,
-	     (MAC_STATUS_SYNC_CHANGED |
-	      MAC_STATUS_CFG_CHANGED |
-	      MAC_STATUS_MI_COMPLETION |
-	      MAC_STATUS_LNKSTATE_CHANGED));
-	udelay(40);
+	tg3_clear_mac_status(tp);
 
 	if (force_reset)
 		tg3_phy_reset(tp);
-- 
1.8.1.4
