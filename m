From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/11] bnxt_en: Add support for firmware updates for additional processors.
Date: Fri,  1 Jul 2016 18:46:24 -0400
Message-ID: <1467413189-29566-7-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36123 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbcGAWqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:48 -0400
Received: by mail-pa0-f47.google.com with SMTP id zl15so1645989pab.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:48 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <rob.swindell@broadcom.com>

Add support to the Ethtool FLASHDEV command handler for additional
firmware types to cover all the on-chip processors.

Signed-off-by: Rob Swindell <rob.swindell@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 20 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h  |  1 +
 2 files changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 12a5141..33b3135 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1094,9 +1094,27 @@ static int bnxt_flash_firmware(struct net_device *dev,
 	case BNX_DIR_TYPE_BOOTCODE_2:
 		code_type = CODE_BOOT;
 		break;
+	case BNX_DIR_TYPE_CHIMP_PATCH:
+		code_type = CODE_CHIMP_PATCH;
+		break;
 	case BNX_DIR_TYPE_APE_FW:
 		code_type = CODE_MCTP_PASSTHRU;
 		break;
+	case BNX_DIR_TYPE_APE_PATCH:
+		code_type = CODE_APE_PATCH;
+		break;
+	case BNX_DIR_TYPE_KONG_FW:
+		code_type = CODE_KONG_FW;
+		break;
+	case BNX_DIR_TYPE_KONG_PATCH:
+		code_type = CODE_KONG_PATCH;
+		break;
+	case BNX_DIR_TYPE_BONO_FW:
+		code_type = CODE_BONO_FW;
+		break;
+	case BNX_DIR_TYPE_BONO_PATCH:
+		code_type = CODE_BONO_PATCH;
+		break;
 	default:
 		netdev_err(dev, "Unsupported directory entry type: %u\n",
 			   dir_type);
@@ -1151,6 +1169,8 @@ static bool bnxt_dir_type_is_ape_bin_format(u16 dir_type)
 	case BNX_DIR_TYPE_APE_PATCH:
 	case BNX_DIR_TYPE_KONG_FW:
 	case BNX_DIR_TYPE_KONG_PATCH:
+	case BNX_DIR_TYPE_BONO_FW:
+	case BNX_DIR_TYPE_BONO_PATCH:
 		return true;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
index 461675c..82bf44a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h
@@ -70,6 +70,7 @@ enum SUPPORTED_CODE {
 	CODE_KONG_PATCH,	/* 18 - KONG Patch firmware */
 	CODE_BONO_FW,		/* 19 - BONO firmware */
 	CODE_BONO_PATCH,	/* 20 - BONO Patch firmware */
+	CODE_CHIMP_PATCH,	/* 21 - ChiMP Patch firmware */
 
 	MAX_CODE_TYPE,
 };
-- 
1.8.3.1
