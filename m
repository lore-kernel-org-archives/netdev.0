From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] vxge: make local functions static
Date: Wed, 15 Jan 2014 08:28:54 -0800
Message-ID: <20140115082854.34b56f21@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46120 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbaAOQ26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:28:58 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so1343092pbc.39
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:28:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused function vxge_hw_vpath_vid_get

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/ethernet/neterion/vxge/vxge-config.c  |    2 -
 drivers/net/ethernet/neterion/vxge/vxge-main.c    |    1 
 drivers/net/ethernet/neterion/vxge/vxge-main.h    |    1 
 drivers/net/ethernet/neterion/vxge/vxge-traffic.c |   37 +---------------------
 drivers/net/ethernet/neterion/vxge/vxge-traffic.h |    8 ----
 5 files changed, 4 insertions(+), 45 deletions(-)

--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c	2014-01-15 08:10:24.862145270 -0800
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c	2014-01-15 08:17:28.164022998 -0800
@@ -2148,7 +2148,7 @@ __vxge_hw_ring_mempool_item_alloc(struct
  * __vxge_hw_ring_replenish - Initial replenish of RxDs
  * This function replenishes the RxDs from reserve array to work array
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 vxge_hw_ring_replenish(struct __vxge_hw_ring *ring)
 {
 	void *rxd;
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c	2014-01-15 08:10:24.862145270 -0800
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c	2014-01-15 08:17:28.164022998 -0800
@@ -87,6 +87,7 @@ static unsigned int bw_percentage[VXGE_H
 module_param_array(bw_percentage, uint, NULL, 0);
 
 static struct vxge_drv_config *driver_config;
+static enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
 
 static inline int is_vxge_card_up(struct vxgedev *vdev)
 {
@@ -1971,7 +1972,7 @@ static enum vxge_hw_status vxge_rth_conf
 }
 
 /* reset vpaths */
-enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
+static enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
 {
 	enum vxge_hw_status status = VXGE_HW_OK;
 	struct vxge_vpath *vpath;
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.h	2014-01-15 08:10:24.862145270 -0800
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.h	2014-01-15 08:17:28.164022998 -0800
@@ -427,7 +427,6 @@ void vxge_os_timer(struct timer_list *ti
 }
 
 void vxge_initialize_ethtool_ops(struct net_device *ndev);
-enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
 int vxge_fw_upgrade(struct vxgedev *vdev, char *fw_name, int override);
 
 /* #define VXGE_DEBUG_INIT: debug for initialization functions
--- a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c	2014-01-15 08:10:24.862145270 -0800
+++ b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c	2014-01-15 08:17:28.168022940 -0800
@@ -1956,8 +1956,7 @@ exit:
  * @vid: vlan id to be added for this vpath into the list
  *
  * Adds the given vlan id into the list for this  vpath.
- * see also: vxge_hw_vpath_vid_delete, vxge_hw_vpath_vid_get and
- * vxge_hw_vpath_vid_get_next
+ * see also: vxge_hw_vpath_vid_delete
  *
  */
 enum vxge_hw_status
@@ -1979,45 +1978,13 @@ exit:
 }
 
 /**
- * vxge_hw_vpath_vid_get - Get the first vid entry for this vpath
- *               from vlan id table.
- * @vp: Vpath handle.
- * @vid: Buffer to return vlan id
- *
- * Returns the first vlan id in the list for this vpath.
- * see also: vxge_hw_vpath_vid_get_next
- *
- */
-enum vxge_hw_status
-vxge_hw_vpath_vid_get(struct __vxge_hw_vpath_handle *vp, u64 *vid)
-{
-	u64 data;
-	enum vxge_hw_status status = VXGE_HW_OK;
-
-	if (vp == NULL) {
-		status = VXGE_HW_ERR_INVALID_HANDLE;
-		goto exit;
-	}
-
-	status = __vxge_hw_vpath_rts_table_get(vp,
-			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_LIST_FIRST_ENTRY,
-			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_VID,
-			0, vid, &data);
-
-	*vid = VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_VLAN_ID(*vid);
-exit:
-	return status;
-}
-
-/**
  * vxge_hw_vpath_vid_delete - Delete the vlan id entry for this vpath
  *               to vlan id table.
  * @vp: Vpath handle.
  * @vid: vlan id to be added for this vpath into the list
  *
  * Adds the given vlan id into the list for this  vpath.
- * see also: vxge_hw_vpath_vid_add, vxge_hw_vpath_vid_get and
- * vxge_hw_vpath_vid_get_next
+ * see also: vxge_hw_vpath_vid_add
  *
  */
 enum vxge_hw_status
--- a/drivers/net/ethernet/neterion/vxge/vxge-traffic.h	2014-01-15 08:10:24.862145270 -0800
+++ b/drivers/net/ethernet/neterion/vxge/vxge-traffic.h	2014-01-15 08:17:28.168022940 -0800
@@ -1918,9 +1918,6 @@ vxge_hw_ring_rxd_post_post(
 	struct __vxge_hw_ring *ring_handle,
 	void *rxdh);
 
-enum vxge_hw_status
-vxge_hw_ring_replenish(struct __vxge_hw_ring *ring_handle);
-
 void
 vxge_hw_ring_rxd_post_post_wmb(
 	struct __vxge_hw_ring *ring_handle,
@@ -2186,11 +2183,6 @@ vxge_hw_vpath_vid_add(
 	u64			vid);
 
 enum vxge_hw_status
-vxge_hw_vpath_vid_get(
-	struct __vxge_hw_vpath_handle *vpath_handle,
-	u64			*vid);
-
-enum vxge_hw_status
 vxge_hw_vpath_vid_delete(
 	struct __vxge_hw_vpath_handle *vpath_handle,
 	u64			vid);
