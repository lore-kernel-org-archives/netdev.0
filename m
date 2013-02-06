From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 1/4] bgmac: implement missing code for BCM53572
Date: Wed,  6 Feb 2013 15:44:57 +0100
Message-ID: <1360161900-2330-2-git-send-email-hauke@hauke-m.de>
References: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34660 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118Ab3BFOpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 09:45:17 -0500
In-Reply-To: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |    6 ++++--
 drivers/net/ethernet/broadcom/bgmac.h |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 9bd33db..58e0c70 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -889,8 +889,10 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			sw_type = et_swtype;
 		} else if (ci->id == BCMA_CHIP_ID_BCM5357 && ci->pkg == 9) {
 			sw_type = BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII;
-		} else if (0) {
-			/* TODO */
+		} else if ((ci->id != BCMA_CHIP_ID_BCM53572 && ci->pkg == 10) ||
+			   (ci->id == BCMA_CHIP_ID_BCM53572 && ci->pkg == 9)) {
+			sw_type = BGMAC_CHIPCTL_1_IF_TYPE_RGMII |
+				  BGMAC_CHIPCTL_1_SW_TYPE_RGMII;
 		}
 		bcma_chipco_chipctl_maskset(cc, 1,
 					    ~(BGMAC_CHIPCTL_1_IF_TYPE_MASK |
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 1299470..3dd6f6f 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -339,7 +339,7 @@
 #define BGMAC_CHIPCTL_1_SW_TYPE_EPHY		0x00000000
 #define BGMAC_CHIPCTL_1_SW_TYPE_EPHYMII		0x00000040
 #define BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII	0x00000080
-#define BGMAC_CHIPCTL_1_SW_TYPE_RGMI		0x000000C0
+#define BGMAC_CHIPCTL_1_SW_TYPE_RGMII		0x000000C0
 #define BGMAC_CHIPCTL_1_RXC_DLL_BYPASS		0x00010000
 
 #define BGMAC_SPEED_10				0x0001
-- 
1.7.10.4
