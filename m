From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 6/10] bnx2x: Added support for a new device -
 57811
Date: Wed, 4 Apr 2012 07:41:28 +0300
Message-ID: <1333514492-20425-7-git-send-email-yuvalmin@broadcom.com>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Barak Witkowski" <barak@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4903 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539Ab2DDEra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 00:47:30 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

Notice this patch includes lines with over 80 characters, as to not
break strings.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    6 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   30 +++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    5 +++
 3 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index ae0dcd4..054ec9e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -815,6 +815,8 @@ struct bnx2x_common {
 #define CHIP_NUM_57800_MF		0x16a5
 #define CHIP_NUM_57810			0x168e
 #define CHIP_NUM_57810_MF		0x16ae
+#define CHIP_NUM_57811			0x163d
+#define CHIP_NUM_57811_MF		0x163e
 #define CHIP_NUM_57840			0x168d
 #define CHIP_NUM_57840_MF		0x16ab
 #define CHIP_IS_E1(bp)			(CHIP_NUM(bp) == CHIP_NUM_57710)
@@ -826,6 +828,8 @@ struct bnx2x_common {
 #define CHIP_IS_57800_MF(bp)		(CHIP_NUM(bp) == CHIP_NUM_57800_MF)
 #define CHIP_IS_57810(bp)		(CHIP_NUM(bp) == CHIP_NUM_57810)
 #define CHIP_IS_57810_MF(bp)		(CHIP_NUM(bp) == CHIP_NUM_57810_MF)
+#define CHIP_IS_57811(bp)		(CHIP_NUM(bp) == CHIP_NUM_57811)
+#define CHIP_IS_57811_MF(bp)		(CHIP_NUM(bp) == CHIP_NUM_57811_MF)
 #define CHIP_IS_57840(bp)		(CHIP_NUM(bp) == CHIP_NUM_57840)
 #define CHIP_IS_57840_MF(bp)		(CHIP_NUM(bp) == CHIP_NUM_57840_MF)
 #define CHIP_IS_E1H(bp)			(CHIP_IS_57711(bp) || \
@@ -836,6 +840,8 @@ struct bnx2x_common {
 					 CHIP_IS_57800_MF(bp) || \
 					 CHIP_IS_57810(bp) || \
 					 CHIP_IS_57810_MF(bp) || \
+					 CHIP_IS_57811(bp) || \
+					 CHIP_IS_57811_MF(bp) || \
 					 CHIP_IS_57840(bp) || \
 					 CHIP_IS_57840_MF(bp))
 #define CHIP_IS_E1x(bp)			(CHIP_IS_E1((bp)) || CHIP_IS_E1H((bp)))
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c5f85ad..faf12d0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -139,7 +139,9 @@ enum bnx2x_board_type {
 	BCM57810,
 	BCM57810_MF,
 	BCM57840,
-	BCM57840_MF
+	BCM57840_MF,
+	BCM57811,
+	BCM57811_MF
 };
 
 /* indexed by board_type, above */
@@ -156,8 +158,9 @@ static struct {
 	{ "Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet" },
 	{ "Broadcom NetXtreme II BCM57810 10 Gigabit Ethernet Multi Function" },
 	{ "Broadcom NetXtreme II BCM57840 10/20 Gigabit Ethernet" },
-	{ "Broadcom NetXtreme II BCM57840 10/20 Gigabit "
-						"Ethernet Multi Function"}
+	{ "Broadcom NetXtreme II BCM57840 10/20 Gigabit Ethernet Multi Function"},
+	{ "Broadcom NetXtreme II BCM57811 10 Gigabit Ethernet"},
+	{ "Broadcom NetXtreme II BCM57811 10 Gigabit Ethernet Multi Function"},
 };
 
 #ifndef PCI_DEVICE_ID_NX2_57710
@@ -193,6 +196,12 @@ static struct {
 #ifndef PCI_DEVICE_ID_NX2_57840_MF
 #define PCI_DEVICE_ID_NX2_57840_MF	CHIP_NUM_57840_MF
 #endif
+#ifndef PCI_DEVICE_ID_NX2_57811
+#define PCI_DEVICE_ID_NX2_57811		CHIP_NUM_57811
+#endif
+#ifndef PCI_DEVICE_ID_NX2_57811_MF
+#define PCI_DEVICE_ID_NX2_57811_MF	CHIP_NUM_57811_MF
+#endif
 static DEFINE_PCI_DEVICE_TABLE(bnx2x_pci_tbl) = {
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57710), BCM57710 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711), BCM57711 },
@@ -205,6 +214,8 @@ static DEFINE_PCI_DEVICE_TABLE(bnx2x_pci_tbl) = {
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57810_MF), BCM57810_MF },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57840), BCM57840 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57840_MF), BCM57840_MF },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57811), BCM57811 },
+	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57811_MF), BCM57811_MF },
 	{ 0 }
 };
 
@@ -8859,6 +8870,17 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	id |= (val & 0xf);
 	bp->common.chip_id = id;
 
+	/* force 57811 according to MISC register */
+	if (REG_RD(bp, MISC_REG_CHIP_TYPE) & MISC_REG_CHIP_TYPE_57811_MASK) {
+		if (CHIP_IS_57810(bp))
+			bp->common.chip_id = (CHIP_NUM_57811 << 16) |
+				(bp->common.chip_id & 0x0000FFFF);
+		else if (CHIP_IS_57810_MF(bp))
+			bp->common.chip_id = (CHIP_NUM_57811_MF << 16) |
+				(bp->common.chip_id & 0x0000FFFF);
+		bp->common.chip_id |= 0x1;
+	}
+
 	/* Set doorbell size */
 	bp->db_size = (1 << BNX2X_DB_SHIFT);
 
@@ -10975,6 +10997,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	case BCM57810_MF:
 	case BCM57840:
 	case BCM57840_MF:
+	case BCM57811:
+	case BCM57811_MF:
 		max_cos_est = BNX2X_MULTI_TX_COS_E3B0;
 		break;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index fd7fb45..2db0380 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -1482,6 +1482,11 @@
    starts at 0x0 for the A0 tape-out and increments by one for each
    all-layer tape-out. */
 #define MISC_REG_CHIP_REV					 0xa40c
+/* [R 14] otp_misc_do[100:0] spare bits collection: 13:11-
+ * otp_misc_do[100:98]; 10:7 - otp_misc_do[87:84]; 6:3 - otp_misc_do[75:72];
+ * 2:1 - otp_misc_do[51:50]; 0 - otp_misc_do[1]. */
+#define MISC_REG_CHIP_TYPE					 0xac60
+#define MISC_REG_CHIP_TYPE_57811_MASK				 (1<<1)
 /* [RW 32] The following driver registers(1...16) represent 16 drivers and
    32 clients. Each client can be controlled by one driver only. One in each
    bit represent that this driver control the appropriate client (Ex: bit 5
-- 
1.7.9.rc2
