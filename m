From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 09/12] vxge: correct multi-function detection
Date: Thu, 11 Nov 2010 08:26:01 -0600
Message-ID: <1289485564-8822-10-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64088 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756790Ab0KKO1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 09:27:18 -0500
Received: by mail-gx0-f174.google.com with SMTP id 23so1162812gxk.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 06:27:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The values used to determined if the adapter is running in single or
multi-function mode were previously modified to the values necessary
when making the VXGE_HW_FW_API_GET_FUNC_MODE firmware call.  However,
the firmware call was not modified.  This had the driver printing out on
probe that the adapter was in multi-function mode when in single
function mode and vice versa.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.c |    6 +++---
 drivers/net/vxge/vxge-reg.h    |    3 +++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 5903b2e..14dc8c8 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -1091,16 +1091,16 @@ __vxge_hw_vpath_pci_func_mode_get(struct __vxge_hw_virtualpath *vpath,
 	u64 data0, data1 = 0, steer_ctrl = 0;
 	enum vxge_hw_status status;
 
-	data0 = VXGE_HW_RTS_ACCESS_STEER_DATA0_MEMO_ITEM_PCI_MODE;
+	data0 = 0;
 
 	status = vxge_hw_vpath_fw_api(vpath,
-			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_MEMO_ENTRY,
+			VXGE_HW_FW_API_GET_FUNC_MODE,
 			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO,
 			0, &data0, &data1, &steer_ctrl);
 	if (status != VXGE_HW_OK)
 		return status;
 
-	hw_info->function_mode = data0;
+	hw_info->function_mode = VXGE_HW_GET_FUNC_MODE_VAL(data0);
 	return status;
 }
 
diff --git a/drivers/net/vxge/vxge-reg.h b/drivers/net/vxge/vxge-reg.h
index 0df52db..3e658b1 100644
--- a/drivers/net/vxge/vxge-reg.h
+++ b/drivers/net/vxge/vxge-reg.h
@@ -62,6 +62,9 @@
 #define VXGE_HW_GET_EPROM_IMAGE_REV(val)		vxge_bVALn(val, 48, 16)
 #define VXGE_HW_RTS_ACCESS_STEER_ROM_IMAGE_INDEX(val)	vxge_vBIT(val, 16, 8)
 
+#define VXGE_HW_FW_API_GET_FUNC_MODE			29
+#define VXGE_HW_GET_FUNC_MODE_VAL(val)			(val & 0xFF)
+
 #define VXGE_HW_FW_UPGRADE_MEMO				13
 #define VXGE_HW_FW_UPGRADE_ACTION			16
 #define VXGE_HW_FW_UPGRADE_OFFSET_START			2
-- 
1.7.0.4

