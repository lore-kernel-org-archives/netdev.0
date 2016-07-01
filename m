From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/11] bnxt_en: Add support for updating flash more securely
Date: Fri,  1 Jul 2016 18:46:22 -0400
Message-ID: <1467413189-29566-5-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34862 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbcGAWqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:46 -0400
Received: by mail-pa0-f47.google.com with SMTP id hl6so42284867pac.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:46 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <rob.swindell@broadcom.com>

To support Secure Firmware Update, we must be able to allocate
a staging area in the Flash.  This patch adds support for the
"update" type to tell firmware to do that.

Signed-off-by: Rob Swindell <rob.swindell@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  | 3 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index c63ed2f..3328aa5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1186,7 +1186,8 @@ static int bnxt_flash_firmware_from_file(struct net_device *dev,
 	const struct firmware  *fw;
 	int			rc;
 
-	if (bnxt_dir_type_is_executable(dir_type) == false)
+	if (dir_type != BNX_DIR_TYPE_UPDATE &&
+	    bnxt_dir_type_is_executable(dir_type) == false)
 		return -EINVAL;
 
 	rc = request_firmware(&fw, filename, &dev->dev);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
index 40a7b0e..73f2249 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
@@ -13,6 +13,7 @@
 enum bnxt_nvm_directory_type {
 	BNX_DIR_TYPE_UNUSED = 0,
 	BNX_DIR_TYPE_PKG_LOG = 1,
+	BNX_DIR_TYPE_UPDATE = 2,
 	BNX_DIR_TYPE_CHIMP_PATCH = 3,
 	BNX_DIR_TYPE_BOOTCODE = 4,
 	BNX_DIR_TYPE_VPD = 5,
-- 
1.8.3.1
