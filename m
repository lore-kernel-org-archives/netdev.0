From: Kumar Amit Mehta <gmate.amit@gmail.com>
Subject: [PATCH] ethernet: neterion: vxge: vxge-traffic.c: fix for a potential NULL pointer dereference
Date: Sat, 16 Feb 2013 09:56:34 -0800
Message-ID: <1361037394-14731-1-git-send-email-gmate.amit@gmail.com>
Cc: davem@davemloft.net, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fix for a potential NULL pointer dereference and removal of a redundant
assignment operation. Found using smatch.

Signed-off-by: Kumar Amit Mehta <gmate.amit@gmail.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-traffic.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
index 99749bd..adb05a8 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
@@ -611,11 +611,8 @@ __vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
 	struct vxge_hw_vpath_stats_sw_info *sw_stats;
 	struct vxge_hw_vpath_reg __iomem *vp_reg;
 
-	if (vpath == NULL) {
-		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
-			alarm_event);
+	if (vpath == NULL)
 		goto out2;
-	}
 
 	hldev = vpath->hldev;
 	vp_reg = vpath->vp_reg;
@@ -852,13 +849,12 @@ __vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
 	}
 out:
 	hldev->stats.sw_dev_err_stats.vpath_alarms++;
+	__vxge_hw_device_handle_error(hldev, vpath->vp_id, alarm_event);
 out2:
 	if ((alarm_event == VXGE_HW_EVENT_ALARM_CLEARED) ||
 		(alarm_event == VXGE_HW_EVENT_UNKNOWN))
 		return VXGE_HW_OK;
 
-	__vxge_hw_device_handle_error(hldev, vpath->vp_id, alarm_event);
-
 	if (alarm_event == VXGE_HW_EVENT_SERR)
 		return VXGE_HW_ERR_CRITICAL;
 
-- 
1.7.9.5
