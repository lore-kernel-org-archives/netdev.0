From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 23/34] forcedeth: Fix invalid errno reporting in nv_request_irq()
Date: Fri, 31 Jan 2014 16:08:42 +0100
Message-ID: <d47456e3944250e98e01c2686caa3a836986250b.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 70cf97f..f4270b8 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3952,8 +3952,9 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 			if (optimization_mode == NV_OPTIMIZATION_MODE_THROUGHPUT && !intr_test) {
 				/* Request irq for rx handling */
 				sprintf(np->name_rx, "%s-rx", dev->name);
-				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector,
-						nv_nic_irq_rx, IRQF_SHARED, np->name_rx, dev) != 0) {
+				ret = request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector,
+						  nv_nic_irq_rx, IRQF_SHARED, np->name_rx, dev);
+				if (ret) {
 					netdev_info(dev,
 						    "request_irq failed for rx %d\n",
 						    ret);
@@ -3963,8 +3964,9 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				}
 				/* Request irq for tx handling */
 				sprintf(np->name_tx, "%s-tx", dev->name);
-				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector,
-						nv_nic_irq_tx, IRQF_SHARED, np->name_tx, dev) != 0) {
+				ret = request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector,
+						  nv_nic_irq_tx, IRQF_SHARED, np->name_tx, dev);
+				if (ret) {
 					netdev_info(dev,
 						    "request_irq failed for tx %d\n",
 						    ret);
@@ -3974,8 +3976,9 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				}
 				/* Request irq for link and timer handling */
 				sprintf(np->name_other, "%s-other", dev->name);
-				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector,
-						nv_nic_irq_other, IRQF_SHARED, np->name_other, dev) != 0) {
+				ret = request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector,
+						  nv_nic_irq_other, IRQF_SHARED, np->name_other, dev);
+				if (ret) {
 					netdev_info(dev,
 						    "request_irq failed for link %d\n",
 						    ret);
@@ -3991,7 +3994,9 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				set_msix_vector_map(dev, NV_MSI_X_VECTOR_OTHER, NVREG_IRQ_OTHER);
 			} else {
 				/* Request irq for all interrupts */
-				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector, handler, IRQF_SHARED, dev->name, dev) != 0) {
+				ret = request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector,
+						  handler, IRQF_SHARED, dev->name, dev);
+				if (ret) {
 					netdev_info(dev,
 						    "request_irq failed %d\n",
 						    ret);
@@ -4011,7 +4016,8 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 		ret = pci_enable_msi(np->pci_dev);
 		if (ret == 0) {
 			np->msi_flags |= NV_MSI_ENABLED;
-			if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0) {
+			ret = request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev);
+			if (ret) {
 				netdev_info(dev, "request_irq failed %d\n",
 					    ret);
 				pci_disable_msi(np->pci_dev);
-- 
1.7.7.6
