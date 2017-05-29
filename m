From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/7] bnxt_en: Add additional chip ID definitions.
Date: Mon, 29 May 2017 19:06:07 -0400
Message-ID: <1496099170-701-5-git-send-email-michael.chan@broadcom.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:35960 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbdE2XGu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 19:06:50 -0400
Received: by mail-qt0-f181.google.com with SMTP id f55so58554828qta.3
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 16:06:44 -0700 (PDT)
In-Reply-To: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add additional chip definitions and macros for all supported chips.
Add a new macro BNXT_CHIP_P4_PLUS for the newer generation of chips and
use the macro to properly determine the features supported by these
newer chips.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |  6 ++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 29 +++++++++++++++++++++++++----
 2 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 63d23b6..427db49 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7712,7 +7712,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	init_waitqueue_head(&bp->sriov_cfg_wait);
 #endif
 	bp->gro_func = bnxt_gro_func_5730x;
-	if (BNXT_CHIP_NUM_57X1X(bp->chip_num))
+	if (BNXT_CHIP_P4_PLUS(bp))
 		bp->gro_func = bnxt_gro_func_5731x;
 
 	rc = bnxt_hwrm_func_drv_rgtr(bp);
@@ -7763,9 +7763,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV4 |
 			   VNIC_RSS_CFG_REQ_HASH_TYPE_IPV6 |
 			   VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV6;
-	if (!BNXT_CHIP_NUM_57X0X(bp->chip_num) &&
-	    !BNXT_CHIP_TYPE_NITRO_A0(bp) &&
-	    bp->hwrm_spec_code >= 0x10501) {
+	if (BNXT_CHIP_P4_PLUS(bp) && bp->hwrm_spec_code >= 0x10501) {
 		bp->flags |= BNXT_FLAG_UDP_RSS_CAP;
 		bp->rss_hash_cfg |= VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV4 |
 				    VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV6;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index cb56678..c59b2cd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -938,31 +938,45 @@ struct bnxt {
 #define CHIP_NUM_57402		0x16d0
 #define CHIP_NUM_57404		0x16d1
 #define CHIP_NUM_57406		0x16d2
+#define CHIP_NUM_57407		0x16d5
 
 #define CHIP_NUM_57311		0x16ce
 #define CHIP_NUM_57312		0x16cf
 #define CHIP_NUM_57314		0x16df
+#define CHIP_NUM_57317		0x16e0
 #define CHIP_NUM_57412		0x16d6
 #define CHIP_NUM_57414		0x16d7
 #define CHIP_NUM_57416		0x16d8
 #define CHIP_NUM_57417		0x16d9
+#define CHIP_NUM_57412L		0x16da
+#define CHIP_NUM_57414L		0x16db
+
+#define CHIP_NUM_5745X		0xd730
 
 #define BNXT_CHIP_NUM_5730X(chip_num)		\
 	((chip_num) >= CHIP_NUM_57301 &&	\
 	 (chip_num) <= CHIP_NUM_57304)
 
 #define BNXT_CHIP_NUM_5740X(chip_num)		\
-	((chip_num) >= CHIP_NUM_57402 &&	\
-	 (chip_num) <= CHIP_NUM_57406)
+	(((chip_num) >= CHIP_NUM_57402 &&	\
+	  (chip_num) <= CHIP_NUM_57406) ||	\
+	 (chip_num) == CHIP_NUM_57407)
 
 #define BNXT_CHIP_NUM_5731X(chip_num)		\
 	((chip_num) == CHIP_NUM_57311 ||	\
 	 (chip_num) == CHIP_NUM_57312 ||	\
-	 (chip_num) == CHIP_NUM_57314)
+	 (chip_num) == CHIP_NUM_57314 ||	\
+	 (chip_num) == CHIP_NUM_57317)
 
 #define BNXT_CHIP_NUM_5741X(chip_num)		\
 	((chip_num) >= CHIP_NUM_57412 &&	\
-	 (chip_num) <= CHIP_NUM_57417)
+	 (chip_num) <= CHIP_NUM_57414L)
+
+#define BNXT_CHIP_NUM_58700(chip_num)		\
+	 ((chip_num) == CHIP_NUM_58700)
+
+#define BNXT_CHIP_NUM_5745X(chip_num)		\
+	 ((chip_num) == CHIP_NUM_5745X)
 
 #define BNXT_CHIP_NUM_57X0X(chip_num)		\
 	(BNXT_CHIP_NUM_5730X(chip_num) || BNXT_CHIP_NUM_5740X(chip_num))
@@ -1022,6 +1036,13 @@ struct bnxt {
 #define BNXT_CHIP_TYPE_NITRO_A0(bp) ((bp)->flags & BNXT_FLAG_CHIP_NITRO_A0)
 #define BNXT_RX_PAGE_MODE(bp)	((bp)->flags & BNXT_FLAG_RX_PAGE_MODE)
 
+/* Chip class phase 4 and later */
+#define BNXT_CHIP_P4_PLUS(bp)			\
+	(BNXT_CHIP_NUM_57X1X((bp)->chip_num) ||	\
+	 BNXT_CHIP_NUM_5745X((bp)->chip_num) ||	\
+	 (BNXT_CHIP_NUM_58700((bp)->chip_num) &&	\
+	  !BNXT_CHIP_TYPE_NITRO_A0(bp)))
+
 	struct bnxt_en_dev	*edev;
 	struct bnxt_en_dev *	(*ulp_probe)(struct net_device *);
 
-- 
1.8.3.1
