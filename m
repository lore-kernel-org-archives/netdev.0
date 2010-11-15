From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/11] drivers/net/vxge/vxge-main.c: Remove unnecessary casts of pci_get_drvdata
Date: Mon, 15 Nov 2010 12:13:58 -0800
Message-ID: <41a52736f96be0f61003a830b6e23e00f9a5d53b.1289851770.git.joe@perches.com>
References: <cover.1289851770.git.joe@perches.com>
Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1337 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933676Ab0KOUOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 15:14:11 -0500
In-Reply-To: <cover.1289851770.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/vxge/vxge-main.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 3f2d6ed..22c7d79 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -688,7 +688,7 @@ static int vxge_learn_mac(struct vxgedev *vdev, u8 *mac_header)
 	struct vxge_vpath *vpath = NULL;
 	struct __vxge_hw_device *hldev;
 
-	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
+	hldev = pci_get_drvdata(vdev->pdev);
 
 	mac_address = (u8 *)&mac_addr;
 	memcpy(mac_address, mac_header, ETH_ALEN);
@@ -1313,7 +1313,7 @@ static void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
 	struct __vxge_hw_device *hldev;
 	int msix_id;
 
-	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
+	hldev = pci_get_drvdata(vdev->pdev);
 
 	vxge_hw_vpath_wait_receive_idle(hldev, vpath->device_id);
 
@@ -1632,8 +1632,7 @@ static int vxge_poll_inta(struct napi_struct *napi, int budget)
 	int budget_org = budget;
 	struct vxge_ring *ring;
 
-	struct __vxge_hw_device *hldev = (struct __vxge_hw_device *)
-		pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev = pci_get_drvdata(vdev->pdev);
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
 		ring = &vdev->vpaths[i].ring;
@@ -1673,7 +1672,7 @@ static void vxge_netpoll(struct net_device *dev)
 	struct vxgedev *vdev;
 
 	vdev = (struct vxgedev *)netdev_priv(dev);
-	hldev = (struct __vxge_hw_device  *)pci_get_drvdata(vdev->pdev);
+	hldev = pci_get_drvdata(vdev->pdev);
 
 	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
 
@@ -2107,7 +2106,7 @@ static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 	vxge_debug_intr(VXGE_TRACE, "%s:%d", __func__, __LINE__);
 
 	dev = vdev->ndev;
-	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
+	hldev = pci_get_drvdata(vdev->pdev);
 
 	if (pci_channel_offline(vdev->pdev))
 		return IRQ_NONE;
@@ -2342,7 +2341,7 @@ static void vxge_rem_msix_isr(struct vxgedev *vdev)
 static void vxge_rem_isr(struct vxgedev *vdev)
 {
 	struct __vxge_hw_device *hldev;
-	hldev = (struct __vxge_hw_device  *)pci_get_drvdata(vdev->pdev);
+	hldev = pci_get_drvdata(vdev->pdev);
 
 #ifdef CONFIG_PCI_MSI
 	if (vdev->config.intr_type == MSI_X) {
@@ -2583,7 +2582,7 @@ vxge_open(struct net_device *dev)
 		"%s: %s:%d", dev->name, __func__, __LINE__);
 
 	vdev = (struct vxgedev *)netdev_priv(dev);
-	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
+	hldev = pci_get_drvdata(vdev->pdev);
 	function_mode = vdev->config.device_hw_info.function_mode;
 
 	/* make sure you have link off by default every time Nic is
@@ -2811,7 +2810,7 @@ static int do_vxge_close(struct net_device *dev, int do_io)
 		dev->name, __func__, __LINE__);
 
 	vdev = (struct vxgedev *)netdev_priv(dev);
-	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
+	hldev = pci_get_drvdata(vdev->pdev);
 
 	if (unlikely(!is_vxge_card_up(vdev)))
 		return 0;
@@ -3985,8 +3984,7 @@ static int vxge_pm_resume(struct pci_dev *pdev)
 static pci_ers_result_t vxge_io_error_detected(struct pci_dev *pdev,
 						pci_channel_state_t state)
 {
-	struct __vxge_hw_device *hldev =
-		(struct __vxge_hw_device  *)pci_get_drvdata(pdev);
+	struct __vxge_hw_device *hldev = pci_get_drvdata(pdev);
 	struct net_device *netdev = hldev->ndev;
 
 	netif_device_detach(netdev);
@@ -4015,8 +4013,7 @@ static pci_ers_result_t vxge_io_error_detected(struct pci_dev *pdev,
  */
 static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev)
 {
-	struct __vxge_hw_device *hldev =
-		(struct __vxge_hw_device  *)pci_get_drvdata(pdev);
+	struct __vxge_hw_device *hldev = pci_get_drvdata(pdev);
 	struct net_device *netdev = hldev->ndev;
 
 	struct vxgedev *vdev = netdev_priv(netdev);
@@ -4041,8 +4038,7 @@ static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev)
  */
 static void vxge_io_resume(struct pci_dev *pdev)
 {
-	struct __vxge_hw_device *hldev =
-		(struct __vxge_hw_device  *)pci_get_drvdata(pdev);
+	struct __vxge_hw_device *hldev = pci_get_drvdata(pdev);
 	struct net_device *netdev = hldev->ndev;
 
 	if (netif_running(netdev)) {
@@ -4689,7 +4685,7 @@ static void __devexit vxge_remove(struct pci_dev *pdev)
 	struct net_device *dev;
 	int i = 0;
 
-	hldev = (struct __vxge_hw_device  *)pci_get_drvdata(pdev);
+	hldev = pci_get_drvdata(pdev);
 
 	if (hldev == NULL)
 		return;
-- 
1.7.3.1.g432b3.dirty

