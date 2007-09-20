From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.23][BNX2]: Add PHY workaround for 5709 A1.
Date: Thu, 20 Sep 2007 11:07:13 -0700
Message-ID: <1190311633.6934.1.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3295 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799AbXITRJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 13:09:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add PHY workaround for 5709 A1.

Add the DIS_EARLY_DAC PHY workaround for 5709 A1.  Without it, link
sometimes does not come up.

Update version to 1.6.5.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 854d80c..66eed22 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.6.4"
-#define DRV_MODULE_RELDATE	"August 3, 2007"
+#define DRV_MODULE_VERSION	"1.6.5"
+#define DRV_MODULE_RELDATE	"September 20, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -6727,7 +6727,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	} else if (CHIP_NUM(bp) == CHIP_NUM_5706 ||
 		   CHIP_NUM(bp) == CHIP_NUM_5708)
 		bp->phy_flags |= PHY_CRC_FIX_FLAG;
-	else if (CHIP_ID(bp) == CHIP_ID_5709_A0)
+	else if (CHIP_ID(bp) == CHIP_ID_5709_A0 ||
+		 CHIP_ID(bp) == CHIP_ID_5709_A1)
 		bp->phy_flags |= PHY_DIS_EARLY_DAC_FLAG;
 
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||


