From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/8] tg3: Fix link flap at 100Mbps with EEE
 enabled
Date: Wed, 20 Jul 2011 13:20:51 -0700
Message-ID: <1311193257-20531-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2265 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699Ab1GTUTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 16:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increases the scope of the EEE interoperability workaround
to include more asic revisions.  The workarond value is tuned to
workaround a link flap issue at 100Mbps.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    9 +++++----
 drivers/net/tg3.h |    2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5bf7671..2a9ab99 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3131,15 +3131,16 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 		switch (GET_ASIC_REV(tp->pci_chip_rev_id)) {
 		case ASIC_REV_5717:
 		case ASIC_REV_57765:
-			if (!tg3_phydsp_read(tp, MII_TG3_DSP_CH34TP2, &val))
-				tg3_phydsp_write(tp, MII_TG3_DSP_CH34TP2, val |
-						 MII_TG3_DSP_CH34TP2_HIBW01);
-			/* Fall through */
 		case ASIC_REV_5719:
 			val = MII_TG3_DSP_TAP26_ALNOKO |
 			      MII_TG3_DSP_TAP26_RMRXSTO |
 			      MII_TG3_DSP_TAP26_OPCSINPT;
 			tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, val);
+			/* Fall through */
+		case ASIC_REV_5720:
+			if (!tg3_phydsp_read(tp, MII_TG3_DSP_CH34TP2, &val))
+				tg3_phydsp_write(tp, MII_TG3_DSP_CH34TP2, val |
+						 MII_TG3_DSP_CH34TP2_HIBW01);
 		}
 
 		val = 0;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6a43fc5..691539b 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2180,7 +2180,7 @@
 #define  MII_TG3_DSP_TAP26_OPCSINPT	0x0004
 #define MII_TG3_DSP_AADJ1CH0		0x001f
 #define MII_TG3_DSP_CH34TP2		0x4022
-#define MII_TG3_DSP_CH34TP2_HIBW01	0x017b
+#define MII_TG3_DSP_CH34TP2_HIBW01	0x01ff
 #define MII_TG3_DSP_AADJ1CH3		0x601f
 #define  MII_TG3_DSP_AADJ1CH3_ADCCKADJ	0x0002
 #define MII_TG3_DSP_EXP1_INT_STAT	0x0f01
-- 
1.7.3.4


