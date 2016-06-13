From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/11] bnxt_en: Define the supported chip numbers.
Date: Mon, 13 Jun 2016 02:25:33 -0400
Message-ID: <1465799138-27529-7-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35496 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161081AbcFMGZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:57 -0400
Received: by mail-pf0-f178.google.com with SMTP id c2so42976812pfa.2
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:56 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define all the supported chip numbers and chip categories.  Store the
chip_num returned by firmware.  If the call to get the version and chip
number fails, we should abort.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c |  6 ++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 38 +++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 1cf885a..0fd27b0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4037,6 +4037,8 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 	if (resp->hwrm_intf_maj >= 1)
 		bp->hwrm_max_req_len = le16_to_cpu(resp->max_req_win_len);
 
+	bp->chip_num = le16_to_cpu(resp->chip_num);
+
 hwrm_ver_get_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
@@ -6414,7 +6416,9 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto init_err;
 
 	mutex_init(&bp->hwrm_cmd_lock);
-	bnxt_hwrm_ver_get(bp);
+	rc = bnxt_hwrm_ver_get(bp);
+	if (rc)
+		goto init_err;
 
 	rc = bnxt_hwrm_func_drv_rgtr(bp);
 	if (rc)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index ec18a07..b754be6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -873,6 +873,44 @@ struct bnxt {
 	void __iomem		*bar2;
 
 	u32			reg_base;
+	u16			chip_num;
+#define CHIP_NUM_57301		0x16c8
+#define CHIP_NUM_57302		0x16c9
+#define CHIP_NUM_57304		0x16ca
+#define CHIP_NUM_57402		0x16d0
+#define CHIP_NUM_57404		0x16d1
+#define CHIP_NUM_57406		0x16d2
+
+#define CHIP_NUM_57311		0x16ce
+#define CHIP_NUM_57312		0x16cf
+#define CHIP_NUM_57314		0x16df
+#define CHIP_NUM_57412		0x16d6
+#define CHIP_NUM_57414		0x16d7
+#define CHIP_NUM_57416		0x16d8
+#define CHIP_NUM_57417		0x16d9
+
+#define BNXT_CHIP_NUM_5730X(chip_num)		\
+	((chip_num) >= CHIP_NUM_57301 &&	\
+	 (chip_num) <= CHIP_NUM_57304)
+
+#define BNXT_CHIP_NUM_5740X(chip_num)		\
+	((chip_num) >= CHIP_NUM_57402 &&	\
+	 (chip_num) <= CHIP_NUM_57406)
+
+#define BNXT_CHIP_NUM_5731X(chip_num)		\
+	((chip_num) == CHIP_NUM_57311 ||	\
+	 (chip_num) == CHIP_NUM_57312 ||	\
+	 (chip_num) == CHIP_NUM_57314)
+
+#define BNXT_CHIP_NUM_5741X(chip_num)		\
+	((chip_num) >= CHIP_NUM_57412 &&	\
+	 (chip_num) <= CHIP_NUM_57417)
+
+#define BNXT_CHIP_NUM_57X0X(chip_num)		\
+	(BNXT_CHIP_NUM_5730X(chip_num) || BNXT_CHIP_NUM_5740X(chip_num))
+
+#define BNXT_CHIP_NUM_57X1X(chip_num)		\
+	(BNXT_CHIP_NUM_5731X(chip_num) || BNXT_CHIP_NUM_5741X(chip_num))
 
 	struct net_device	*dev;
 	struct pci_dev		*pdev;
-- 
1.8.3.1
