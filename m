From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 11/12] vxge: sparse and other clean-ups
Date: Thu, 11 Nov 2010 08:26:03 -0600
Message-ID: <1289485564-8822-12-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45298 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787Ab0KKO1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 09:27:30 -0500
Received: by mail-yx0-f174.google.com with SMTP id 8so34940yxk.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 06:27:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct issues found by running sparse on the vxge driver, as well as
other miscellaneous cleanups.

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/vxge/vxge-config.c  |  100 +++++++++------------------------------
 drivers/net/vxge/vxge-ethtool.c |   35 +++++--------
 drivers/net/vxge/vxge-main.c    |   94 +++++++++++++++---------------------
 3 files changed, 76 insertions(+), 153 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 14dc8c8..409c2e6 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -22,19 +22,6 @@
 #include "vxge-main.h"
 
 static enum vxge_hw_status
-__vxge_hw_fifo_create(
-	struct __vxge_hw_vpath_handle *vpath_handle,
-	struct vxge_hw_fifo_attr *attr);
-
-static enum vxge_hw_status
-__vxge_hw_fifo_abort(
-	struct __vxge_hw_fifo *fifoh);
-
-static enum vxge_hw_status
-__vxge_hw_fifo_reset(
-	struct __vxge_hw_fifo *ringh);
-
-static enum vxge_hw_status
 __vxge_hw_fifo_delete(
 	struct __vxge_hw_vpath_handle *vpath_handle);
 
@@ -72,44 +59,15 @@ __vxge_hw_blockpool_free(struct __vxge_hw_device *hldev,
 			u32 size,
 			struct vxge_hw_mempool_dma *dma_object);
 
-
-static struct __vxge_hw_channel*
-__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
-			enum __vxge_hw_channel_type type, u32 length,
-			u32 per_dtr_space, void *userdata);
-
 static void
 __vxge_hw_channel_free(
 	struct __vxge_hw_channel *channel);
 
-static enum vxge_hw_status
-__vxge_hw_channel_initialize(
-	struct __vxge_hw_channel *channel);
-
-static enum vxge_hw_status
-__vxge_hw_channel_reset(
-	struct __vxge_hw_channel *channel);
-
 static enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp);
 
 static enum vxge_hw_status
-__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config);
-
-static enum vxge_hw_status
 __vxge_hw_device_config_check(struct vxge_hw_device_config *new_config);
 
-static void
-__vxge_hw_device_host_info_get(struct __vxge_hw_device *hldev);
-
-static enum vxge_hw_status
-__vxge_hw_device_initialize(struct __vxge_hw_device *hldev);
-
-static void
-__vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev);
-
-static enum vxge_hw_status
-__vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev);
-
 static enum vxge_hw_status
 __vxge_hw_device_register_poll(
 	void __iomem	*reg,
@@ -130,9 +88,10 @@ __vxge_hw_pio_mem_write64(u64 val64, void __iomem *addr,
 
 static struct vxge_hw_mempool*
 __vxge_hw_mempool_create(struct __vxge_hw_device *devh, u32 memblock_size,
-			 u32 item_size,	u32 private_size, u32 items_initial,
-			 u32 items_max,	struct vxge_hw_mempool_cbs *mp_callback,
-			 void *userdata);
+			u32 item_size, u32 private_size, u32 items_initial,
+			u32 items_max, struct vxge_hw_mempool_cbs *mp_callback,
+			void *userdata);
+
 static void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool);
 
 static enum vxge_hw_status
@@ -145,24 +104,10 @@ vxge_hw_vpath_stats_enable(struct __vxge_hw_vpath_handle *vpath_handle);
 static enum vxge_hw_status
 __vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg);
 
-static enum vxge_hw_status
-__vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath);
-
-
-static enum vxge_hw_status
-__vxge_hw_vpath_sw_reset(struct __vxge_hw_device *devh, u32 vp_id);
-
-static enum vxge_hw_status
-__vxge_hw_vpath_mac_configure(struct __vxge_hw_device *devh, u32 vp_id);
-
 static void
 __vxge_hw_vp_terminate(struct __vxge_hw_device *devh, u32 vp_id);
 
 static enum vxge_hw_status
-__vxge_hw_vpath_stats_access(struct __vxge_hw_virtualpath *vpath,
-			     u32 operation, u32 offset,	u64 *stat);
-
-static enum vxge_hw_status
 __vxge_hw_vpath_xmac_tx_stats_get(struct __vxge_hw_virtualpath	*vpath,
 				  struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats);
 
@@ -505,7 +450,7 @@ vxge_hw_vpath_eprom_img_ver_get(struct __vxge_hw_device *hldev,
  * This function allocates required memory for the channel and various arrays
  * in the channel
  */
-struct __vxge_hw_channel*
+static struct __vxge_hw_channel *
 __vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
 			   enum __vxge_hw_channel_type type,
 	u32 length, u32 per_dtr_space, void *userdata)
@@ -576,7 +521,7 @@ exit0:
  * This function deallocates memory from the channel and various arrays
  * in the channel
  */
-void __vxge_hw_channel_free(struct __vxge_hw_channel *channel)
+static void __vxge_hw_channel_free(struct __vxge_hw_channel *channel)
 {
 	kfree(channel->work_arr);
 	kfree(channel->free_arr);
@@ -590,7 +535,7 @@ void __vxge_hw_channel_free(struct __vxge_hw_channel *channel)
  * This function initializes a channel by properly setting the
  * various references
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_channel_initialize(struct __vxge_hw_channel *channel)
 {
 	u32 i;
@@ -625,7 +570,7 @@ __vxge_hw_channel_initialize(struct __vxge_hw_channel *channel)
  * __vxge_hw_channel_reset - Resets a channel
  * This function resets a channel by properly setting the various references
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_channel_reset(struct __vxge_hw_channel *channel)
 {
 	u32 i;
@@ -652,8 +597,7 @@ __vxge_hw_channel_reset(struct __vxge_hw_channel *channel)
  * Initialize certain PCI/PCI-X configuration registers
  * with recommended values. Save config space for future hw resets.
  */
-void
-__vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev)
+static void __vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev)
 {
 	u16 cmd = 0;
 
@@ -742,7 +686,7 @@ exit:
  * register location pointers in the device object. It waits until the ric is
  * completed initializing registers.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev)
 {
 	u64 val64;
@@ -938,7 +882,8 @@ __vxge_hw_verify_pci_e_info(struct __vxge_hw_device *hldev)
  * __vxge_hw_device_initialize
  * Initialize Titan-V hardware.
  */
-enum vxge_hw_status __vxge_hw_device_initialize(struct __vxge_hw_device *hldev)
+static enum vxge_hw_status
+__vxge_hw_device_initialize(struct __vxge_hw_device *hldev)
 {
 	enum vxge_hw_status status = VXGE_HW_OK;
 
@@ -2337,7 +2282,7 @@ static void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
  * __vxge_hw_device_fifo_config_check - Check fifo configuration.
  * Check the fifo configuration
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config)
 {
 	if ((fifo_config->fifo_blocks < VXGE_HW_MIN_FIFO_BLOCKS) ||
@@ -2385,7 +2330,7 @@ __vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config)
  * __vxge_hw_device_config_check - Check device configuration.
  * Check the device configuration
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_device_config_check(struct vxge_hw_device_config *new_config)
 {
 	u32 i;
@@ -2945,7 +2890,7 @@ __vxge_hw_fifo_mempool_item_alloc(
  * __vxge_hw_fifo_create - Create a FIFO
  * This function creates FIFO and initializes it.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_fifo_create(struct __vxge_hw_vpath_handle *vp,
 		      struct vxge_hw_fifo_attr *attr)
 {
@@ -3109,7 +3054,8 @@ static enum vxge_hw_status __vxge_hw_fifo_reset(struct __vxge_hw_fifo *fifo)
  * __vxge_hw_fifo_delete - Removes the FIFO
  * This function freeup the memory pool and removes the FIFO
  */
-enum vxge_hw_status __vxge_hw_fifo_delete(struct __vxge_hw_vpath_handle *vp)
+static enum vxge_hw_status
+__vxge_hw_fifo_delete(struct __vxge_hw_vpath_handle *vp)
 {
 	struct __vxge_hw_fifo *fifo = vp->vpath->fifoh;
 
@@ -4897,7 +4843,7 @@ static void vxge_os_dma_free(struct pci_dev *pdev, const void *vaddr,
  * __vxge_hw_blockpool_create - Create block pool
  */
 
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
 			   struct __vxge_hw_blockpool *blockpool,
 			   u32 pool_size,
@@ -4997,7 +4943,7 @@ blockpool_create_exit:
  * __vxge_hw_blockpool_destroy - Deallocates the block pool
  */
 
-void __vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool *blockpool)
+static void __vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool *blockpool)
 {
 
 	struct __vxge_hw_device *hldev;
@@ -5163,7 +5109,7 @@ exit:
  * Allocates a block of memory of given size, either from block pool
  * or by calling vxge_os_dma_malloc()
  */
-void *
+static void *
 __vxge_hw_blockpool_malloc(struct __vxge_hw_device *devh, u32 size,
 				struct vxge_hw_mempool_dma *dma_object)
 {
@@ -5227,7 +5173,7 @@ exit:
  * __vxge_hw_blockpool_free - Frees the memory allcoated with
 				__vxge_hw_blockpool_malloc
  */
-void
+static void
 __vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
 			void *memblock, u32 size,
 			struct vxge_hw_mempool_dma *dma_object)
@@ -5279,7 +5225,7 @@ __vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
  * __vxge_hw_blockpool_block_allocate - Allocates a block from block pool
  * This function allocates a block from block pool or from the system
  */
-struct __vxge_hw_blockpool_entry *
+static struct __vxge_hw_blockpool_entry *
 __vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *devh, u32 size)
 {
 	struct __vxge_hw_blockpool_entry *entry = NULL;
@@ -5314,7 +5260,7 @@ __vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *devh, u32 size)
  *
  * This function frees a block from block pool
  */
-void
+static void
 __vxge_hw_blockpool_block_free(struct __vxge_hw_device *devh,
 			struct __vxge_hw_blockpool_entry *entry)
 {
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
index 3d2cd6a..09f721e 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -11,7 +11,7 @@
  *                 Virtualized Server Adapter.
  * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
-#include<linux/ethtool.h>
+#include <linux/ethtool.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
 #include <linux/etherdevice.h>
@@ -29,7 +29,6 @@
  * Return value:
  * 0 on success.
  */
-
 static int vxge_ethtool_sset(struct net_device *dev, struct ethtool_cmd *info)
 {
 	/* We currently only support 10Gb/FULL */
@@ -79,10 +78,9 @@ static int vxge_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
  * Returns driver specefic information like name, version etc.. to ethtool.
  */
 static void vxge_ethtool_gdrvinfo(struct net_device *dev,
-			struct ethtool_drvinfo *info)
+				  struct ethtool_drvinfo *info)
 {
-	struct vxgedev *vdev;
-	vdev = (struct vxgedev *)netdev_priv(dev);
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
 	strlcpy(info->driver, VXGE_DRIVER_NAME, sizeof(VXGE_DRIVER_NAME));
 	strlcpy(info->version, DRV_VERSION, sizeof(DRV_VERSION));
 	strlcpy(info->fw_version, vdev->fw_version, VXGE_HW_FW_STRLEN);
@@ -104,15 +102,14 @@ static void vxge_ethtool_gdrvinfo(struct net_device *dev,
  * buffer area.
  */
 static void vxge_ethtool_gregs(struct net_device *dev,
-			struct ethtool_regs *regs, void *space)
+			       struct ethtool_regs *regs, void *space)
 {
 	int index, offset;
 	enum vxge_hw_status status;
 	u64 reg;
-	u64 *reg_space = (u64 *) space;
+	u64 *reg_space = (u64 *)space;
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device *)
-					pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev = vdev->devh;
 
 	regs->len = sizeof(struct vxge_hw_vpath_reg) * vdev->no_of_vpath;
 	regs->version = vdev->pdev->subsystem_device;
@@ -148,8 +145,7 @@ static void vxge_ethtool_gregs(struct net_device *dev,
 static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
 {
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
-			pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev = vdev->devh;
 
 	vxge_hw_device_flick_link_led(hldev, VXGE_FLICKER_ON);
 	msleep_interruptible(data ? (data * HZ) : VXGE_MAX_FLICKER_TIME);
@@ -168,11 +164,10 @@ static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
  *  void
  */
 static void vxge_ethtool_getpause_data(struct net_device *dev,
-					struct ethtool_pauseparam *ep)
+				       struct ethtool_pauseparam *ep)
 {
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
-			pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev = vdev->devh;
 
 	vxge_hw_device_getpause_data(hldev, 0, &ep->tx_pause, &ep->rx_pause);
 }
@@ -188,11 +183,10 @@ static void vxge_ethtool_getpause_data(struct net_device *dev,
  * int, returns 0 on Success
  */
 static int vxge_ethtool_setpause_data(struct net_device *dev,
-					struct ethtool_pauseparam *ep)
+				      struct ethtool_pauseparam *ep)
 {
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
-			pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev = vdev->devh;
 
 	vxge_hw_device_setpause_data(hldev, 0, ep->tx_pause, ep->rx_pause);
 
@@ -209,9 +203,8 @@ static void vxge_get_ethtool_stats(struct net_device *dev,
 	enum vxge_hw_status status;
 	enum vxge_hw_status swstatus;
 	struct vxge_vpath *vpath = NULL;
-
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = vdev->devh;
+	struct __vxge_hw_device *hldev = vdev->devh;
 	struct vxge_hw_xmac_stats *xmac_stats;
 	struct vxge_hw_device_stats_sw_info *sw_stats;
 	struct vxge_hw_device_stats_hw_info *hw_stats;
@@ -574,8 +567,8 @@ static void vxge_get_ethtool_stats(struct net_device *dev,
 	kfree(hw_stats);
 }
 
-static void vxge_ethtool_get_strings(struct net_device *dev,
-			      u32 stringset, u8 *data)
+static void vxge_ethtool_get_strings(struct net_device *dev, u32 stringset,
+				     u8 *data)
 {
 	int stat_size = 0;
 	int i, j;
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index b8806a1..3f2d6ed 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -688,7 +688,7 @@ static int vxge_learn_mac(struct vxgedev *vdev, u8 *mac_header)
 	struct vxge_vpath *vpath = NULL;
 	struct __vxge_hw_device *hldev;
 
-	hldev = (struct __vxge_hw_device *) pci_get_drvdata(vdev->pdev);
+	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
 
 	mac_address = (u8 *)&mac_addr;
 	memcpy(mac_address, mac_header, ETH_ALEN);
@@ -1112,7 +1112,7 @@ static void vxge_set_multicast(struct net_device *dev)
 		/* Delete previous MC's */
 		for (i = 0; i < mcast_cnt; i++) {
 			list_for_each_safe(entry, next, list_head) {
-				mac_entry = (struct vxge_mac_addrs *) entry;
+				mac_entry = (struct vxge_mac_addrs *)entry;
 				/* Copy the mac address to delete */
 				mac_address = (u8 *)&mac_entry->macaddr;
 				memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
@@ -1155,7 +1155,7 @@ _set_all_mcast:
 		/* Delete previous MC's */
 		for (i = 0; i < mcast_cnt; i++) {
 			list_for_each_safe(entry, next, list_head) {
-				mac_entry = (struct vxge_mac_addrs *) entry;
+				mac_entry = (struct vxge_mac_addrs *)entry;
 				/* Copy the mac address to delete */
 				mac_address = (u8 *)&mac_entry->macaddr;
 				memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
@@ -1202,7 +1202,7 @@ static int vxge_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 	struct vxgedev *vdev;
-	struct __vxge_hw_device  *hldev;
+	struct __vxge_hw_device *hldev;
 	enum vxge_hw_status status = VXGE_HW_OK;
 	struct macInfo mac_info_new, mac_info_old;
 	int vpath_idx = 0;
@@ -1632,7 +1632,7 @@ static int vxge_poll_inta(struct napi_struct *napi, int budget)
 	int budget_org = budget;
 	struct vxge_ring *ring;
 
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device *)
+	struct __vxge_hw_device *hldev = (struct __vxge_hw_device *)
 		pci_get_drvdata(vdev->pdev);
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
@@ -1669,7 +1669,7 @@ static int vxge_poll_inta(struct napi_struct *napi, int budget)
  */
 static void vxge_netpoll(struct net_device *dev)
 {
-	struct __vxge_hw_device  *hldev;
+	struct __vxge_hw_device *hldev;
 	struct vxgedev *vdev;
 
 	vdev = (struct vxgedev *)netdev_priv(dev);
@@ -1821,7 +1821,7 @@ static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
 {
 	struct list_head *entry, *next;
 	u64 del_mac = 0;
-	u8 *mac_address = (u8 *) (&del_mac);
+	u8 *mac_address = (u8 *)(&del_mac);
 
 	/* Copy the mac address to delete from the list */
 	memcpy(mac_address, mac->macaddr, ETH_ALEN);
@@ -2102,7 +2102,7 @@ static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 	struct __vxge_hw_device *hldev;
 	u64 reason;
 	enum vxge_hw_status status;
-	struct vxgedev *vdev = (struct vxgedev *) dev_id;;
+	struct vxgedev *vdev = (struct vxgedev *)dev_id;
 
 	vxge_debug_intr(VXGE_TRACE, "%s:%d", __func__, __LINE__);
 
@@ -2341,8 +2341,8 @@ static void vxge_rem_msix_isr(struct vxgedev *vdev)
 
 static void vxge_rem_isr(struct vxgedev *vdev)
 {
-	struct __vxge_hw_device  *hldev;
-	hldev = (struct __vxge_hw_device  *) pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev;
+	hldev = (struct __vxge_hw_device  *)pci_get_drvdata(vdev->pdev);
 
 #ifdef CONFIG_PCI_MSI
 	if (vdev->config.intr_type == MSI_X) {
@@ -2583,7 +2583,7 @@ vxge_open(struct net_device *dev)
 		"%s: %s:%d", dev->name, __func__, __LINE__);
 
 	vdev = (struct vxgedev *)netdev_priv(dev);
-	hldev = (struct __vxge_hw_device *) pci_get_drvdata(vdev->pdev);
+	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
 	function_mode = vdev->config.device_hw_info.function_mode;
 
 	/* make sure you have link off by default every time Nic is
@@ -2811,7 +2811,7 @@ static int do_vxge_close(struct net_device *dev, int do_io)
 		dev->name, __func__, __LINE__);
 
 	vdev = (struct vxgedev *)netdev_priv(dev);
-	hldev = (struct __vxge_hw_device *) pci_get_drvdata(vdev->pdev);
+	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
 
 	if (unlikely(!is_vxge_card_up(vdev)))
 		return 0;
@@ -3440,36 +3440,29 @@ _out0:
  *
  * This function will unregister and free network device
  */
-static void
-vxge_device_unregister(struct __vxge_hw_device *hldev)
+static void vxge_device_unregister(struct __vxge_hw_device *hldev)
 {
 	struct vxgedev *vdev;
 	struct net_device *dev;
 	char buf[IFNAMSIZ];
-#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
-	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
-	u32 level_trace;
-#endif
 
 	dev = hldev->ndev;
 	vdev = netdev_priv(dev);
-#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
-	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
-	level_trace = vdev->level_trace;
-#endif
-	vxge_debug_entryexit(level_trace,
-		"%s: %s:%d", vdev->ndev->name, __func__, __LINE__);
 
-	memcpy(buf, vdev->ndev->name, IFNAMSIZ);
+	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d", vdev->ndev->name,
+			     __func__, __LINE__);
+
+	memcpy(buf, dev->name, IFNAMSIZ);
 
 	/* in 2.6 will call stop() if device is up */
 	unregister_netdev(dev);
 
 	flush_scheduled_work();
 
-	vxge_debug_init(level_trace, "%s: ethernet device unregistered", buf);
-	vxge_debug_entryexit(level_trace,
-		"%s: %s:%d  Exiting...", buf, __func__, __LINE__);
+	vxge_debug_init(vdev->level_trace, "%s: ethernet device unregistered",
+			buf);
+	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d  Exiting...", buf,
+			     __func__, __LINE__);
 }
 
 /*
@@ -3992,8 +3985,8 @@ static int vxge_pm_resume(struct pci_dev *pdev)
 static pci_ers_result_t vxge_io_error_detected(struct pci_dev *pdev,
 						pci_channel_state_t state)
 {
-	struct __vxge_hw_device  *hldev =
-		(struct __vxge_hw_device  *) pci_get_drvdata(pdev);
+	struct __vxge_hw_device *hldev =
+		(struct __vxge_hw_device  *)pci_get_drvdata(pdev);
 	struct net_device *netdev = hldev->ndev;
 
 	netif_device_detach(netdev);
@@ -4022,8 +4015,8 @@ static pci_ers_result_t vxge_io_error_detected(struct pci_dev *pdev,
  */
 static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev)
 {
-	struct __vxge_hw_device  *hldev =
-		(struct __vxge_hw_device  *) pci_get_drvdata(pdev);
+	struct __vxge_hw_device *hldev =
+		(struct __vxge_hw_device  *)pci_get_drvdata(pdev);
 	struct net_device *netdev = hldev->ndev;
 
 	struct vxgedev *vdev = netdev_priv(netdev);
@@ -4048,8 +4041,8 @@ static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev)
  */
 static void vxge_io_resume(struct pci_dev *pdev)
 {
-	struct __vxge_hw_device  *hldev =
-		(struct __vxge_hw_device  *) pci_get_drvdata(pdev);
+	struct __vxge_hw_device *hldev =
+		(struct __vxge_hw_device  *)pci_get_drvdata(pdev);
 	struct net_device *netdev = hldev->ndev;
 
 	if (netif_running(netdev)) {
@@ -4243,7 +4236,7 @@ static int vxge_probe_fw_update(struct vxgedev *vdev)
 static int __devinit
 vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 {
-	struct __vxge_hw_device  *hldev;
+	struct __vxge_hw_device *hldev;
 	enum vxge_hw_status status;
 	int ret;
 	int high_dma = 0;
@@ -4689,34 +4682,25 @@ _exit0:
  * Description: This function is called by the Pci subsystem to release a
  * PCI device and free up all resource held up by the device.
  */
-static void __devexit
-vxge_remove(struct pci_dev *pdev)
+static void __devexit vxge_remove(struct pci_dev *pdev)
 {
-	struct __vxge_hw_device  *hldev;
+	struct __vxge_hw_device *hldev;
 	struct vxgedev *vdev = NULL;
 	struct net_device *dev;
 	int i = 0;
-#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
-	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
-	u32 level_trace;
-#endif
 
-	hldev = (struct __vxge_hw_device  *) pci_get_drvdata(pdev);
+	hldev = (struct __vxge_hw_device  *)pci_get_drvdata(pdev);
 
 	if (hldev == NULL)
 		return;
+
 	dev = hldev->ndev;
 	vdev = netdev_priv(dev);
 
-#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
-	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
-	level_trace = vdev->level_trace;
-#endif
-	vxge_debug_entryexit(level_trace,
-		"%s:%d", __func__, __LINE__);
+	vxge_debug_entryexit(vdev->level_trace,	"%s:%d", __func__, __LINE__);
 
-	vxge_debug_init(level_trace,
-		"%s : removing PCI device...", __func__);
+	vxge_debug_init(vdev->level_trace, "%s : removing PCI device...",
+			__func__);
 	vxge_device_unregister(hldev);
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
@@ -4734,16 +4718,16 @@ vxge_remove(struct pci_dev *pdev)
 	/* we are safe to free it now */
 	free_netdev(dev);
 
-	vxge_debug_init(level_trace,
-		"%s:%d  Device unregistered", __func__, __LINE__);
+	vxge_debug_init(vdev->level_trace, "%s:%d Device unregistered",
+			__func__, __LINE__);
 
 	vxge_hw_device_terminate(hldev);
 
 	pci_disable_device(pdev);
 	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
-	vxge_debug_entryexit(level_trace,
-		"%s:%d  Exiting...", __func__, __LINE__);
+	vxge_debug_entryexit(vdev->level_trace,	"%s:%d  Exiting...", __func__,
+			     __LINE__);
 }
 
 static struct pci_error_handlers vxge_err_handler = {
-- 
1.7.0.4

