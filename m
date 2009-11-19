From: Joe Perches <joe@perches.com>
Subject: [PATCH] drivers/net: tasklet_init - Remove unnecessary leading &
 from second arg
Date: Thu, 19 Nov 2009 11:30:10 -0800
Message-ID: <1258659010.3863.11.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1049 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753212AbZKSTaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 14:30:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed function pointer use from non-majority address-of style
to majority short form without & via: (was: 8 with &, 36 without)

grep -rPl "\btasklet_init\s*\([^,\)]+,\s*\&" drivers/net | while read file ; do \
	perl -i -e 'local $/; while (<>) { s@(\btasklet_init\s*\([^,\)]+,\s*)\&@\1@g ; print ; }' $file ;\
done

Compile tested allyesconfig x86

Signed-off-by: Joe Perches <joe@perches.com>

 drivers/net/cnic.c |    4 ++--
 drivers/net/jme.c  |   10 +++++-----
 drivers/net/skge.c |    2 +-
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index e503384..ee7eb9e 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3387,7 +3387,7 @@ static int cnic_init_bnx2_irq(struct cnic_dev *dev)
 
 		cp->bnx2_status_blk = cp->status_blk;
 		cp->last_status_idx = cp->bnx2_status_blk->status_idx;
-		tasklet_init(&cp->cnic_irq_task, &cnic_service_bnx2_msix,
+		tasklet_init(&cp->cnic_irq_task, cnic_service_bnx2_msix,
 			     (unsigned long) dev);
 		err = request_irq(ethdev->irq_arr[0].vector, cnic_irq, 0,
 				  "cnic", dev);
@@ -3787,7 +3787,7 @@ static int cnic_init_bnx2x_irq(struct cnic_dev *dev)
 	struct cnic_eth_dev *ethdev = cp->ethdev;
 	int err = 0;
 
-	tasklet_init(&cp->cnic_irq_task, &cnic_service_bnx2x_bh,
+	tasklet_init(&cp->cnic_irq_task, cnic_service_bnx2x_bh,
 		     (unsigned long) dev);
 	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
 		err = request_irq(ethdev->irq_arr[0].vector, cnic_irq, 0,
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 1d2a325..6c1b92f 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2764,19 +2764,19 @@ jme_init_one(struct pci_dev *pdev,
 	atomic_set(&jme->rx_empty, 1);
 
 	tasklet_init(&jme->pcc_task,
-		     &jme_pcc_tasklet,
+		     jme_pcc_tasklet,
 		     (unsigned long) jme);
 	tasklet_init(&jme->linkch_task,
-		     &jme_link_change_tasklet,
+		     jme_link_change_tasklet,
 		     (unsigned long) jme);
 	tasklet_init(&jme->txclean_task,
-		     &jme_tx_clean_tasklet,
+		     jme_tx_clean_tasklet,
 		     (unsigned long) jme);
 	tasklet_init(&jme->rxclean_task,
-		     &jme_rx_clean_tasklet,
+		     jme_rx_clean_tasklet,
 		     (unsigned long) jme);
 	tasklet_init(&jme->rxempty_task,
-		     &jme_rx_empty_tasklet,
+		     jme_rx_empty_tasklet,
 		     (unsigned long) jme);
 	tasklet_disable_nosync(&jme->linkch_task);
 	tasklet_disable_nosync(&jme->txclean_task);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index ba5eb14..34b4e7d 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3947,7 +3947,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	hw->pdev = pdev;
 	spin_lock_init(&hw->hw_lock);
 	spin_lock_init(&hw->phy_lock);
-	tasklet_init(&hw->phy_task, &skge_extirq, (unsigned long) hw);
+	tasklet_init(&hw->phy_task, skge_extirq, (unsigned long) hw);
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {


