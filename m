From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH] csiostor:Use firmware version from cxgb4/t4fw_version.h
Date: Tue,  3 Feb 2015 17:18:26 +0530
Message-ID: <1422964106-4033-1-git-send-email-praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, praveenm@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to use firmware version macros from t4fw_version.h
and also enables 40g T5 adapter.

Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>
---
 drivers/scsi/csiostor/csio_hw.c      | 6 ++++--
 drivers/scsi/csiostor/csio_hw_chip.h | 6 +-----
 drivers/scsi/csiostor/csio_mb.c      | 3 ++-
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index c81b06b..2e66f34 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -1372,7 +1372,8 @@ csio_config_device_caps(struct csio_hw *hw)
 	}
 
 	/* Validate device capabilities */
-	if (csio_hw_validate_caps(hw, mbp))
+	rv = csio_hw_validate_caps(hw, mbp);
+	if (rv != 0)
 		goto out;
 
 	/* Don't config device capabilities if already configured */
@@ -1776,7 +1777,8 @@ csio_hw_use_fwconfig(struct csio_hw *hw, int reset, u32 *fw_cfg_param)
 	}
 
 	/* Validate device capabilities */
-	if (csio_hw_validate_caps(hw, mbp))
+	rv = csio_hw_validate_caps(hw, mbp);
+	if (rv != 0)
 		goto bye;
 	/*
 	 * Note that we're operating with parameters
diff --git a/drivers/scsi/csiostor/csio_hw_chip.h b/drivers/scsi/csiostor/csio_hw_chip.h
index a5f624f..b56a11d 100644
--- a/drivers/scsi/csiostor/csio_hw_chip.h
+++ b/drivers/scsi/csiostor/csio_hw_chip.h
@@ -45,11 +45,6 @@
 #define FW_FNAME_T5				"cxgb4/t5fw.bin"
 #define FW_CFG_NAME_T5				"cxgb4/t5-config.txt"
 
-#define T5FW_VERSION_MAJOR 0x01
-#define T5FW_VERSION_MINOR 0x0B
-#define T5FW_VERSION_MICRO 0x1B
-#define T5FW_VERSION_BUILD 0x00
-
 #define CHELSIO_CHIP_CODE(version, revision) (((version) << 4) | (revision))
 #define CHELSIO_CHIP_FPGA          0x100
 #define CHELSIO_CHIP_VERSION(code) (((code) >> 12) & 0xf)
@@ -74,6 +69,7 @@ static inline int csio_is_t5(uint16_t chip)
 	{ PCI_VENDOR_ID_CHELSIO, (devid), PCI_ANY_ID, PCI_ANY_ID, 0, 0, (idx) }
 
 #include "t4fw_api.h"
+#include "t4fw_version.h"
 
 #define FW_VERSION(chip) ( \
 		FW_HDR_FW_VER_MAJOR_G(chip##FW_VERSION_MAJOR) | \
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index 1132c41..9451787 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -327,7 +327,8 @@ csio_mb_caps_config(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 }
 
 #define CSIO_ADVERT_MASK     (FW_PORT_CAP_SPEED_100M | FW_PORT_CAP_SPEED_1G |\
-			      FW_PORT_CAP_SPEED_10G | FW_PORT_CAP_ANEG)
+			      FW_PORT_CAP_SPEED_10G | FW_PORT_CAP_SPEED_40G |\
+			      FW_PORT_CAP_ANEG)
 
 /*
  * csio_mb_port- FW PORT command helper
-- 
2.0.2

