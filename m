From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 2/7] bna: Capability Map and MFG Block Changes for New HW
Date: Mon, 26 Sep 2011 14:12:16 -0700
Message-ID: <1317071541-9662-3-git-send-email-rmody@brocade.com>
References: <1317071541-9662-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:44254 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752120Ab1IZVMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 17:12:34 -0400
In-Reply-To: <1317071541-9662-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add capability map and generic model name scheme for manufacturing block.
Add card types for new HW.

Remove bfa_mfg_is_card_type_valid and ibfa_mfg_adapter_prop_init_flash_ct
macros.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_defs.h        |   12 +++++-
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |   44 +++----------------
 2 files changed, 18 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index a81c0cc..66a6207 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -241,7 +241,17 @@ struct bfa_mfg_block {
 	u8		num_mac;	/*!< number of mac addresses */
 	u8		rsv2;
 	u32		card_type;	/*!< card type */
-	u8		rsv3[108];
+	char		cap_nic;	/*!< capability nic */
+	char		cap_cna;	/*!< capability cna */
+	char		cap_hba;	/*!< capability hba */
+	char		cap_fc16g;	/*!< capability fc 16g */
+	char		cap_sriov;	/*!< capability sriov */
+	char		cap_mezz;	/*!< capability mezz */
+	u8		rsv3;
+	u8		mfg_nports;	/*!< number of ports */
+	char		media[8];	/*!< xfi/xaui */
+	char		initial_mode[8];/*!< initial mode: hba/cna/nic */
+	u8		rsv4[84];
 	u8		md5_chksum[BFA_MFG_CHKSUM_SIZE]; /*!< md5 checksum */
 };
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
index 7e5df90..6681fe8 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
@@ -60,6 +60,11 @@ enum {
 	BFA_MFG_TYPE_ASTRA    = 807,	 /*!< Astra mezz card		*/
 	BFA_MFG_TYPE_LIGHTNING_P0 = 902, /*!< Lightning mezz card - old	*/
 	BFA_MFG_TYPE_LIGHTNING = 1741,	 /*!< Lightning mezz card	*/
+	BFA_MFG_TYPE_PROWLER_F = 1560,	 /*!< Prowler FC only cards	*/
+	BFA_MFG_TYPE_PROWLER_N = 1410,	 /*!< Prowler NIC only cards	*/
+	BFA_MFG_TYPE_PROWLER_C = 1710,	 /*!< Prowler CNA only cards	*/
+	BFA_MFG_TYPE_PROWLER_D = 1860,	 /*!< Prowler Dual cards	*/
+	BFA_MFG_TYPE_CHINOOK   = 1867,	 /*!< Chinook cards		*/
 	BFA_MFG_TYPE_INVALID = 0,	 /*!< Invalid card type		*/
 };
 
@@ -73,43 +78,8 @@ enum {
 	(type) == BFA_MFG_TYPE_WANCHESE || \
 	(type) == BFA_MFG_TYPE_ASTRA || \
 	(type) == BFA_MFG_TYPE_LIGHTNING_P0 || \
-	(type) == BFA_MFG_TYPE_LIGHTNING))
-
-/**
- * Check if card type valid
- */
-#define bfa_mfg_is_card_type_valid(type) (( \
-	(type) == BFA_MFG_TYPE_FC8P2 || \
-	(type) == BFA_MFG_TYPE_FC8P1 || \
-	(type) == BFA_MFG_TYPE_FC4P2 || \
-	(type) == BFA_MFG_TYPE_FC4P1 || \
-	(type) == BFA_MFG_TYPE_CNA10P2 || \
-	(type) == BFA_MFG_TYPE_CNA10P1 || \
-	bfa_mfg_is_mezz(type)))
-
-#define bfa_mfg_adapter_prop_init_flash_ct(mfgblk, prop)	\
-do {								\
-	switch ((mfgblk)->card_type) {				\
-	case BFA_MFG_TYPE_JAYHAWK:				\
-	case BFA_MFG_TYPE_ASTRA:				\
-		(prop) = BFI_ADAPTER_SETP(NPORTS, 2) |		\
-			BFI_ADAPTER_SETP(SPEED, 8);		\
-		break;						\
-	case BFA_MFG_TYPE_CNA10P2:				\
-	case BFA_MFG_TYPE_WANCHESE:				\
-	case BFA_MFG_TYPE_LIGHTNING_P0:				\
-	case BFA_MFG_TYPE_LIGHTNING:				\
-		(prop) = BFI_ADAPTER_SETP(NPORTS, 2);		\
-		(prop) |= BFI_ADAPTER_SETP(SPEED, 10);		\
-		break;						\
-	case BFA_MFG_TYPE_CNA10P1:				\
-		(prop) = BFI_ADAPTER_SETP(NPORTS, 1);		\
-		(prop) |= BFI_ADAPTER_SETP(SPEED, 10);		\
-		break;						\
-	default:						\
-		(prop) = BFI_ADAPTER_UNSUPP;			\
-	}							\
-} while (0)
+	(type) == BFA_MFG_TYPE_LIGHTNING || \
+	(type) == BFA_MFG_TYPE_CHINOOK))
 
 enum {
 	CB_GPIO_TTV	= (1),		/*!< TTV debug capable cards	*/
-- 
1.7.1
