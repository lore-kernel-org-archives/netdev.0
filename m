From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 21/34] s2io: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:40 +0100
Message-ID: <d1a9bf16ad8e822bb8fc7d42819f13d08dc8e430.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org,
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
 drivers/net/ethernet/neterion/s2io.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 9eeddbd..56e3a9d 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -3792,9 +3792,10 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	writeq(rx_mat, &bar0->rx_mat);
 	readq(&bar0->rx_mat);
 
-	ret = pci_enable_msix(nic->pdev, nic->entries, nic->num_entries);
+	ret = pci_enable_msix_range(nic->pdev, nic->entries,
+				    nic->num_entries, nic->num_entries);
 	/* We fail init if error or we get less vectors than min required */
-	if (ret) {
+	if (ret < 0) {
 		DBG_PRINT(ERR_DBG, "Enabling MSI-X failed\n");
 		kfree(nic->entries);
 		swstats->mem_freed += nic->num_entries *
-- 
1.7.7.6
