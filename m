From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH v2 net-next 07/12] be2net: remove unncessary gotos
Date: Tue, 2 Sep 2014 09:56:52 +0530
Message-ID: <1409632017-15655-8-git-send-email-sathya.perla@emulex.com>
References: <1409632017-15655-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:26660 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbaIBEYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 00:24:31 -0400
In-Reply-To: <1409632017-15655-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

In cases where there is no extra code to handle an error, this patch replaces
gotos with a direct return statement.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7e89e5b..cdad8bc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4090,18 +4090,15 @@ static int lancer_fw_download(struct be_adapter *adapter,
 
 	if (!IS_ALIGNED(fw->size, sizeof(u32))) {
 		dev_err(dev, "FW image size should be multiple of 4\n");
-		status = -EINVAL;
-		goto lancer_fw_exit;
+		return -EINVAL;
 	}
 
 	flash_cmd.size = sizeof(struct lancer_cmd_req_write_object)
 				+ LANCER_FW_DOWNLOAD_CHUNK;
 	flash_cmd.va = dma_alloc_coherent(dev, flash_cmd.size,
 					  &flash_cmd.dma, GFP_KERNEL);
-	if (!flash_cmd.va) {
-		status = -ENOMEM;
-		goto lancer_fw_exit;
-	}
+	if (!flash_cmd.va)
+		return -ENOMEM;
 
 	dest_image_ptr = flash_cmd.va +
 				sizeof(struct lancer_cmd_req_write_object);
@@ -4139,7 +4136,7 @@ static int lancer_fw_download(struct be_adapter *adapter,
 	dma_free_coherent(dev, flash_cmd.size, flash_cmd.va, flash_cmd.dma);
 	if (status) {
 		dev_err(dev, "Firmware load error\n");
-		goto lancer_fw_exit;
+		return be_cmd_status(status);
 	}
 
 	dev_info(dev, "Firmware flashed successfully\n");
@@ -4151,13 +4148,12 @@ static int lancer_fw_download(struct be_adapter *adapter,
 		if (status) {
 			dev_err(dev, "Adapter busy, could not reset FW\n");
 			dev_err(dev, "Reboot server to activate new FW\n");
-			goto lancer_fw_exit;
 		}
 	} else if (change_status != LANCER_NO_RESET_NEEDED) {
 		dev_info(dev, "Reboot server to activate new FW\n");
 	}
-lancer_fw_exit:
-	return status;
+
+	return 0;
 }
 
 #define UFI_TYPE2		2
-- 
1.7.1
