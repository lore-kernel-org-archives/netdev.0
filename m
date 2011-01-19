From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 2/4] vxge: correct eprom version detection
Date: Tue, 18 Jan 2011 19:02:20 -0600
Message-ID: <1295398942-4131-2-git-send-email-jon.mason@exar.com>
References: <1295398942-4131-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:53137 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965Ab1ASBCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 20:02:34 -0500
Received: by qwa26 with SMTP id 26so263152qwa.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 17:02:34 -0800 (PST)
In-Reply-To: <1295398942-4131-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware PXE EPROM version detection is failing due to passing the
wrong parameter into firmware query function.  Also, the version
printing function has an extraneous newline.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sivakumar Subramani <sivakumar.subramani@exar.com>
---
 drivers/net/vxge/vxge-config.c |    2 +-
 drivers/net/vxge/vxge-main.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 01c05f5..da35562 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -387,8 +387,8 @@ vxge_hw_vpath_eprom_img_ver_get(struct __vxge_hw_device *hldev,
 		data1 = steer_ctrl = 0;
 
 		status = vxge_hw_vpath_fw_api(vpath,
-			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO,
 			VXGE_HW_FW_API_GET_EPROM_REV,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO,
 			0, &data0, &data1, &steer_ctrl);
 		if (status != VXGE_HW_OK)
 			break;
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index cd0698c..9d4b0e8 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4450,7 +4450,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 			if (!img[i].is_valid)
 				break;
 			vxge_debug_init(VXGE_TRACE, "%s: EPROM %d, version "
-					"%d.%d.%d.%d\n", VXGE_DRIVER_NAME, i,
+					"%d.%d.%d.%d", VXGE_DRIVER_NAME, i,
 					VXGE_EPROM_IMG_MAJOR(img[i].version),
 					VXGE_EPROM_IMG_MINOR(img[i].version),
 					VXGE_EPROM_IMG_FIX(img[i].version),
-- 
1.7.0.4

