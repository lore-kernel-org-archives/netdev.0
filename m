From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 09/11] vxge: correct multi-function detection
Date: Thu, 28 Oct 2010 21:19:44 -0500
Message-ID: <1288318786-12319-9-git-send-email-jon.mason@exar.com>
References: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38952 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755810Ab0J2CUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 22:20:22 -0400
Received: by mail-yx0-f174.google.com with SMTP id 8so1381877yxk.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 19:20:22 -0700 (PDT)
In-Reply-To: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
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
index d61d7f4..312c4c1 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -945,16 +945,16 @@ __vxge_hw_vpath_pci_func_mode_get(struct __vxge_hw_virtualpath *vpath,
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
index f9ac574..278daae 100644
--- a/drivers/net/vxge/vxge-reg.h
+++ b/drivers/net/vxge/vxge-reg.h
@@ -62,6 +62,9 @@
 #define VXGE_HW_GET_EPROM_IMAGE_REV(val)		vxge_bVALn(val, 48, 16)
 #define VXGE_HW_RTS_ACCESS_STEER_ROM_IMAGE_INDEX(val)	vxge_vBIT(val, 16, 8)
 
+#define VXGE_HW_FW_API_GET_FUNC_MODE			29
+#define VXGE_HW_GET_FUNC_MODE_VAL(val)			(val & 0xFF)
+
 #define VXGE_HW_BYTES_PER_U64				8
 #define VXGE_HW_FW_UPGRADE_MEMO				13
 #define VXGE_HW_FW_UPGRADE_ACTION			16
-- 
1.7.0.4

