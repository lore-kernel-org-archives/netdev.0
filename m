From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 25/34] forcedeth: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:44 +0100
Message-ID: <76d50819eba2af613e37b97abd328287c5ea346c.1391172839.git.agordeev@redhat.com>
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

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 74da489..bad3c05 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3946,8 +3946,11 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 	if (np->msi_flags & NV_MSI_X_CAPABLE) {
 		for (i = 0; i < (np->msi_flags & NV_MSI_X_VECTORS_MASK); i++)
 			np->msi_x_entry[i].entry = i;
-		ret = pci_enable_msix(np->pci_dev, np->msi_x_entry, (np->msi_flags & NV_MSI_X_VECTORS_MASK));
-		if (ret == 0) {
+		ret = pci_enable_msix_range(np->pci_dev,
+					    np->msi_x_entry,
+					    np->msi_flags & NV_MSI_X_VECTORS_MASK,
+					    np->msi_flags & NV_MSI_X_VECTORS_MASK);
+		if (ret > 0) {
 			np->msi_flags |= NV_MSI_X_ENABLED;
 			if (optimization_mode == NV_OPTIMIZATION_MODE_THROUGHPUT && !intr_test) {
 				/* Request irq for rx handling */
-- 
1.7.7.6
