From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 06/11] qed: Remove BB_A0 references
Date: Tue, 23 May 2017 09:41:23 +0300
Message-ID: <1495521688-27669-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0070.outbound.protection.outlook.com ([104.47.37.70]:27968
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965820AbdEWGmr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 02:42:47 -0400
In-Reply-To: <1495521688-27669-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A0 never went public, so no need to protect against it.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     | 6 ------
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 6 ------
 2 files changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 63c44c6..2eb6031 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -598,16 +598,11 @@ struct qed_dev {
 	enum	qed_dev_type type;
 /* Translate type/revision combo into the proper conditions */
 #define QED_IS_BB(dev)  ((dev)->type == QED_DEV_TYPE_BB)
-#define QED_IS_BB_A0(dev)       (QED_IS_BB(dev) && \
-				 CHIP_REV_IS_A0(dev))
 #define QED_IS_BB_B0(dev)       (QED_IS_BB(dev) && \
 				 CHIP_REV_IS_B0(dev))
 #define QED_IS_AH(dev)  ((dev)->type == QED_DEV_TYPE_AH)
 #define QED_IS_K2(dev)  QED_IS_AH(dev)
 
-#define QED_GET_TYPE(dev)       (QED_IS_BB_A0(dev) ? CHIP_BB_A0 : \
-				 QED_IS_BB_B0(dev) ? CHIP_BB_B0 : CHIP_K2)
-
 	u16	vendor_id;
 	u16	device_id;
 #define QED_DEV_ID_MASK		0xff00
@@ -621,7 +616,6 @@ struct qed_dev {
 	u16	chip_rev;
 #define CHIP_REV_MASK                   0xf
 #define CHIP_REV_SHIFT                  12
-#define CHIP_REV_IS_A0(_cdev)   (!(_cdev)->chip_rev)
 #define CHIP_REV_IS_B0(_cdev)   ((_cdev)->chip_rev == 1)
 
 	u16				chip_metal;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 51ae907..3262aaa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2812,12 +2812,6 @@ static int qed_get_dev_info(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		cdev->chip_num, cdev->chip_rev,
 		cdev->chip_bond_id, cdev->chip_metal);
 
-	if (QED_IS_BB(cdev) && CHIP_REV_IS_A0(cdev)) {
-		DP_NOTICE(cdev->hwfns,
-			  "The chip type/rev (BB A0) is not supported!\n");
-		return -EINVAL;
-	}
-
 	return 0;
 }
 
-- 
1.9.3
