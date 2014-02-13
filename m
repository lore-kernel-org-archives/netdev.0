From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 5/5] ixgbe: fixup warning regarding max_vfs parameter
Date: Thu, 13 Feb 2014 00:00:50 -0800
Message-ID: <1392278450-27062-6-git-send-email-aaron.f.brown@intel.com>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61219 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114AbaBMIDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 03:03:12 -0500
In-Reply-To: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The max_vfs parameter for ixgbe is deprecated in favor of using the
sysfs sriov_numvfs field to assign VFs as needed, instead of fixing the
value at module load time. The current message only indicates that you
should use this, without adequately explaining how to do so.

This patch modifies the warning message to include the command necessary
to spawn VFs via sysfs, and points users to the Documentation for more
information.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e65a5be..bbd41a1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5068,8 +5068,18 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->fc.disable_fc_autoneg = ixgbe_device_supports_autoneg_fc(hw);
 
 #ifdef CONFIG_PCI_IOV
-	if (max_vfs > 0)
-		e_dev_warn("Enabling SR-IOV VFs using the max_vfs module parameter is deprecated - please use the pci sysfs interface instead.\n");
+	if (max_vfs > 0) {
+		e_dev_warn("Enabling SR-IOV VFs using the max_vfs module parameter is deprecated.\n");
+		e_dev_warn("Please use the pci sysfs interface instead. Ex:\n");
+		e_dev_warn("echo '%d' > /sys/bus/pci/devices/%04x:%02x:%02x.%1x/sriov_numvfs\n",
+			   max_vfs,
+			   pci_domain_nr(pdev->bus),
+			   pdev->bus->number,
+			   PCI_SLOT(pdev->devfn),
+			   PCI_FUNC(pdev->devfn)
+			   );
+		e_dev_warn("See 'Documentation/PCI/pci-iov-howto.txt for more information.\n");
+	}
 
 	/* assign number of SR-IOV VFs */
 	if (hw->mac.type != ixgbe_mac_82598EB) {
-- 
1.8.5.GIT
