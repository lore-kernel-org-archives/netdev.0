From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/5] cxgb4: Add warning msg when attaching to adapters which have FLASHes smaller than 2Mb
Date: Wed, 10 Sep 2014 17:44:30 +0530
Message-ID: <1410351271-26428-5-git-send-email-hariprasad@chelsio.com>
References: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:42779
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751344AbaIJMJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:09:08 -0400
In-Reply-To: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    4 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h |    6 ++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 586a5f1..22d7581 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3897,6 +3897,10 @@ static int get_flash_params(struct adapter *adap)
 	adap->params.sf_size = 1 << info;
 	adap->params.sf_fw_start =
 		t4_read_reg(adap, CIM_BOOT_CFG) & BOOTADDR_MASK;
+
+	if (adap->params.sf_size < FLASH_MIN_SIZE)
+		dev_warn(adap->pdev_dev, "WARNING!!! FLASH size %#x < %#x!!!\n",
+			 adap->params.sf_size, FLASH_MIN_SIZE);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 06fa583..6833a7b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -206,6 +206,12 @@ enum {
 	FLASH_CFG_START = FLASH_START(FLASH_CFG_START_SEC),
 	FLASH_CFG_MAX_SIZE = FLASH_MAX_SIZE(FLASH_CFG_NSECS),
 
+	/* We don't support FLASH devices which can't support the full
+	 * standard set of sections which we need for normal
+	 * operations.
+	 */
+	FLASH_MIN_SIZE = FLASH_CFG_START + FLASH_CFG_MAX_SIZE,
+
 	FLASH_FPGA_CFG_START_SEC = 15,
 	FLASH_FPGA_CFG_START = FLASH_START(FLASH_FPGA_CFG_START_SEC),
 
-- 
1.7.1
