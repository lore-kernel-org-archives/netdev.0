From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 02/14] be2net: fix error status for FW-download
Date: Thu, 17 Jul 2014 16:20:20 +0530
Message-ID: <1405594232-30818-3-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:22735 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756760AbaGQKsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:33 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

For FW download ethtool cmd, if the user provides an FW-image incompatible
with the chip, return -EINVAL instead of -1.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index db5fb51..61632f8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3956,7 +3956,7 @@ static int be_flash_skyhawk(struct be_adapter *adapter,
 	fsec = get_fsec_info(adapter, filehdr_size + img_hdrs_size, fw);
 	if (!fsec) {
 		dev_err(dev, "Invalid Cookie. FW image may be corrupted\n");
-		return -1;
+		return -EINVAL;
 	}
 
 	for (i = 0; i < le32_to_cpu(fsec->fsec_hdr.num_images); i++) {
@@ -4187,7 +4187,7 @@ static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
 							      &flash_cmd,
 							      num_imgs);
 				else {
-					status = -1;
+					status = -EINVAL;
 					dev_err(&adapter->pdev->dev,
 						"Can't load BE3 UFI on BE3R\n");
 				}
@@ -4198,7 +4198,7 @@ static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
 	if (ufi_type == UFI_TYPE2)
 		status = be_flash_BEx(adapter, fw, &flash_cmd, 0);
 	else if (ufi_type == -1)
-		status = -1;
+		status = -EINVAL;
 
 	dma_free_coherent(&adapter->pdev->dev, flash_cmd.size, flash_cmd.va,
 			  flash_cmd.dma);
-- 
1.7.1
