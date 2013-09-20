From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 1/8] tg3: Add function tg3_phy_shdw_write()
Date: Fri, 20 Sep 2013 16:46:55 -0700
Message-ID: <1379720822-6500-2-git-send-email-nsujir@broadcom.com>
References: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4371 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044Ab3ITXr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 19:47:26 -0400
In-Reply-To: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For consistency with other register access functions, add shadow
register access function of the type (register/val).

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 5701f3d..d2bc391 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1326,6 +1326,12 @@ static int tg3_phy_toggle_auxctl_smdsp(struct tg3 *tp, bool enable)
 	return err;
 }
 
+static int tg3_phy_shdw_write(struct tg3 *tp, int reg, u32 val)
+{
+	return tg3_writephy(tp, MII_TG3_MISC_SHDW,
+			    reg | val | MII_TG3_MISC_SHDW_WREN);
+}
+
 static int tg3_bmcr_reset(struct tg3 *tp)
 {
 	u32 phy_control;
@@ -2218,25 +2224,21 @@ static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
 		return;
 	}
 
-	reg = MII_TG3_MISC_SHDW_WREN |
-	      MII_TG3_MISC_SHDW_SCR5_SEL |
-	      MII_TG3_MISC_SHDW_SCR5_LPED |
+	reg = MII_TG3_MISC_SHDW_SCR5_LPED |
 	      MII_TG3_MISC_SHDW_SCR5_DLPTLM |
 	      MII_TG3_MISC_SHDW_SCR5_SDTL |
 	      MII_TG3_MISC_SHDW_SCR5_C125OE;
 	if (tg3_asic_rev(tp) != ASIC_REV_5784 || !enable)
 		reg |= MII_TG3_MISC_SHDW_SCR5_DLLAPD;
 
-	tg3_writephy(tp, MII_TG3_MISC_SHDW, reg);
+	tg3_phy_shdw_write(tp, MII_TG3_MISC_SHDW_SCR5_SEL, reg);
 
 
-	reg = MII_TG3_MISC_SHDW_WREN |
-	      MII_TG3_MISC_SHDW_APD_SEL |
-	      MII_TG3_MISC_SHDW_APD_WKTM_84MS;
+	reg = MII_TG3_MISC_SHDW_APD_WKTM_84MS;
 	if (enable)
 		reg |= MII_TG3_MISC_SHDW_APD_ENABLE;
 
-	tg3_writephy(tp, MII_TG3_MISC_SHDW, reg);
+	tg3_phy_shdw_write(tp, MII_TG3_MISC_SHDW_APD_SEL, reg);
 }
 
 static void tg3_phy_toggle_automdix(struct tg3 *tp, bool enable)
-- 
1.8.1.4
