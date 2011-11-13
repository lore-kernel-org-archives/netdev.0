From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v3 net-next 06/12] bnx2x: DCBX: use #define instead of
 magic
Date: Sun, 13 Nov 2011 16:34:26 +0200
Message-ID: <1321194872-8276-7-git-send-email-dmitry@broadcom.com>
References: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4899 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091Ab1KMOeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 09:34:50 -0500
In-Reply-To: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |    6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h |    4 +++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index a0598fd..5051cf3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -874,7 +874,7 @@ static void bnx2x_dcbx_admin_mib_updated_params(struct bnx2x *bp,
 		/*For IEEE admin_recommendation_bw_precentage
 		 *For IEEE admin_recommendation_ets_pg */
 		af->pfc.pri_en_bitmap = (u8)dp->admin_pfc_bitmap;
-		for (i = 0; i < 4; i++) {
+		for (i = 0; i < DCBX_CONFIG_MAX_APP_PROTOCOL; i++) {
 			if (dp->admin_priority_app_table[i].valid) {
 				struct bnx2x_admin_priority_app_table *table =
 					dp->admin_priority_app_table;
@@ -2249,7 +2249,7 @@ static int bnx2x_set_admin_app_up(struct bnx2x *bp, u8 idtype, u16 idval, u8 up)
 	int i, ff;
 
 	/* iterate over the app entries looking for idtype and idval */
-	for (i = 0, ff = -1; i < 4; i++) {
+	for (i = 0, ff = -1; i < DCBX_CONFIG_MAX_APP_PROTOCOL; i++) {
 		struct bnx2x_admin_priority_app_table *app_ent =
 			&bp->dcbx_config_params.admin_priority_app_table[i];
 		if (bnx2x_admin_app_is_equal(app_ent, idtype, idval))
@@ -2258,7 +2258,7 @@ static int bnx2x_set_admin_app_up(struct bnx2x *bp, u8 idtype, u16 idval, u8 up)
 		if (ff < 0 && !app_ent->valid)
 			ff = i;
 	}
-	if (i < 4)
+	if (i < DCBX_CONFIG_MAX_APP_PROTOCOL)
 		/* if found overwrite up */
 		bp->dcbx_config_params.
 			admin_priority_app_table[i].priority = up;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
index 2c6a3bc..2ab9254 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
@@ -90,6 +90,7 @@ struct bnx2x_admin_priority_app_table {
 		u32 app_id;
 };
 
+#define DCBX_CONFIG_MAX_APP_PROTOCOL 4
 struct bnx2x_config_dcbx_params {
 	u32 overwrite_settings;
 	u32 admin_dcbx_version;
@@ -109,7 +110,8 @@ struct bnx2x_config_dcbx_params {
 	u32 admin_recommendation_bw_precentage[8];
 	u32 admin_recommendation_ets_pg[8];
 	u32 admin_pfc_bitmap;
-	struct bnx2x_admin_priority_app_table admin_priority_app_table[4];
+	struct bnx2x_admin_priority_app_table
+		admin_priority_app_table[DCBX_CONFIG_MAX_APP_PROTOCOL];
 	u32 admin_default_priority;
 };
 
-- 
1.7.7.2
