From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH v2 net-next 2/2] qlcnic: Use pci_enable_msix_exact() instead
 of pci_enable_msix()
Date: Fri, 25 Apr 2014 11:43:50 +0200
Message-ID: <20140425094349.GA6397@dhcp-26-207.brq.redhat.com>
References: <cover.1398412015.git.agordeev@redhat.com>
 <0a0d5f5c33d86e3777c22c3c1bbd81035660d57c.1398412015.git.agordeev@redhat.com>
 <262CB373A6D1F14F9B81E82F74F77D5A46F9EE54@avmb2.qlogic.org>
 <20140425090029.GA2500@dhcp-26-207.brq.redhat.com>
 <262CB373A6D1F14F9B81E82F74F77D5A46F9EEA2@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <262CB373A6D1F14F9B81E82F74F77D5A46F9EEA2@avmb2.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range()  or pci_enable_msi_exact()
and pci_enable_msix_range() or pci_enable_msix_exact()
interfaces.

Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
Cc: Dept-HSGLinuxNICDev@qlogic.com
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index dbf7539..73f908a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -690,10 +690,10 @@ int qlcnic_setup_tss_rss_intr(struct qlcnic_adapter *adapter)
 		adapter->msix_entries[vector].entry = vector;
 
 restore:
-	err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
-	if (err > 0) {
+	err = pci_enable_msix_exact(pdev, adapter->msix_entries, num_msix);
+	if (err == -ENOSPC) {
 		if (!adapter->drv_tss_rings && !adapter->drv_rss_rings)
-			return -ENOSPC;
+			return err;
 
 		netdev_info(adapter->netdev,
 			    "Unable to allocate %d MSI-X vectors, Available vectors %d\n",
-- 
1.7.7.6

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
