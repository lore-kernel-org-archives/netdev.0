From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 10/11] vxge: Remove useless return variables
Date: Sat, 31 May 2014 10:14:10 -0300
Message-ID: <1401542051-3174-10-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch remove variables that are initialized with a constant,
are never updated, and are only used as parameter of return.
Return the constant instead of using a variable.

Verified by compilation only.

The coccinelle script that find and fixes this issue is:
// <smpl>
@@
type T;
constant C;
identifier ret;
@@
- T ret = C;
... when != ret
    when strict
return
- ret
+ C
;
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/ethernet/neterion/vxge/vxge-config.c |   22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
index 089b713..2bbd01f 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c
@@ -120,7 +120,6 @@ __vxge_hw_device_register_poll(void __iomem *reg, u64 mask, u32 max_millis)
 {
 	u64 val64;
 	u32 i = 0;
-	enum vxge_hw_status ret = VXGE_HW_FAIL;
 
 	udelay(10);
 
@@ -139,7 +138,7 @@ __vxge_hw_device_register_poll(void __iomem *reg, u64 mask, u32 max_millis)
 		mdelay(1);
 	} while (++i <= max_millis);
 
-	return ret;
+	return VXGE_HW_FAIL;
 }
 
 static inline enum vxge_hw_status
@@ -1682,12 +1681,10 @@ enum vxge_hw_status vxge_hw_driver_stats_get(
 			struct __vxge_hw_device *hldev,
 			struct vxge_hw_device_stats_sw_info *sw_stats)
 {
-	enum vxge_hw_status status = VXGE_HW_OK;
-
 	memcpy(sw_stats, &hldev->stats.sw_dev_info_stats,
 		sizeof(struct vxge_hw_device_stats_sw_info));
 
-	return status;
+	return VXGE_HW_OK;
 }
 
 /*
@@ -3228,7 +3225,6 @@ enum vxge_hw_status
 vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask)
 {
 	struct vxge_hw_vpmgmt_reg       __iomem *vpmgmt_reg;
-	enum vxge_hw_status status = VXGE_HW_OK;
 	int i = 0, j = 0;
 
 	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
@@ -3241,7 +3237,7 @@ vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask)
 				return VXGE_HW_FAIL;
 		}
 	}
-	return status;
+	return VXGE_HW_OK;
 }
 /*
  * vxge_hw_mgmt_reg_Write - Write Titan register.
@@ -3979,7 +3975,6 @@ __vxge_hw_vpath_mgmt_read(
 {
 	u32 i, mtu = 0, max_pyld = 0;
 	u64 val64;
-	enum vxge_hw_status status = VXGE_HW_OK;
 
 	for (i = 0; i < VXGE_HW_MAC_MAX_MAC_PORT_ID; i++) {
 
@@ -4009,7 +4004,7 @@ __vxge_hw_vpath_mgmt_read(
 	else
 		VXGE_HW_DEVICE_LINK_STATE_SET(vpath->hldev, VXGE_HW_LINK_DOWN);
 
-	return status;
+	return VXGE_HW_OK;
 }
 
 /*
@@ -4039,14 +4034,13 @@ static enum vxge_hw_status
 __vxge_hw_vpath_reset(struct __vxge_hw_device *hldev, u32 vp_id)
 {
 	u64 val64;
-	enum vxge_hw_status status = VXGE_HW_OK;
 
 	val64 = VXGE_HW_CMN_RSTHDLR_CFG0_SW_RESET_VPATH(1 << (16 - vp_id));
 
 	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32),
 				&hldev->common_reg->cmn_rsthdlr_cfg0);
 
-	return status;
+	return VXGE_HW_OK;
 }
 
 /*
@@ -4227,7 +4221,6 @@ static enum vxge_hw_status
 __vxge_hw_vpath_mac_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 {
 	u64 val64;
-	enum vxge_hw_status status = VXGE_HW_OK;
 	struct __vxge_hw_virtualpath *vpath;
 	struct vxge_hw_vp_config *vp_config;
 	struct vxge_hw_vpath_reg __iomem *vp_reg;
@@ -4283,7 +4276,7 @@ __vxge_hw_vpath_mac_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 
 		writeq(val64, &vp_reg->rxmac_vcfg1);
 	}
-	return status;
+	return VXGE_HW_OK;
 }
 
 /*
@@ -4295,7 +4288,6 @@ static enum vxge_hw_status
 __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 {
 	u64 val64;
-	enum vxge_hw_status status = VXGE_HW_OK;
 	struct __vxge_hw_virtualpath *vpath;
 	struct vxge_hw_vpath_reg __iomem *vp_reg;
 	struct vxge_hw_vp_config *config;
@@ -4545,7 +4537,7 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 	val64 |= VXGE_HW_TIM_WRKLD_CLC_CNT_RX_TX(3);
 	writeq(val64, &vp_reg->tim_wrkld_clc);
 
-	return status;
+	return VXGE_HW_OK;
 }
 
 /*
