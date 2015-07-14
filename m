From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH] e1000e: Move e1000e_disable_aspm_locked() inside CONFIG_PM
Date: Tue, 14 Jul 2015 13:54:35 +1000
Message-ID: <1436846075-29366-1-git-send-email-mpe@ellerman.id.au>
Cc: <linux-kernel@vger.kernel.org>, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, aaron.f.brown@intel.com,
	yanirx.lubetkin@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

e1000e_disable_aspm_locked() is only used in __e1000_resume() which is
inside CONFIG_PM. So when CONFIG_PM=n we get a "defined but not used"
warning for e1000e_disable_aspm_locked().

Move it inside the existing CONFIG_PM block to avoid the warning.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 89d788d8f263..f1d7fe2ea183 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6439,6 +6439,7 @@ static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 	__e1000e_disable_aspm(pdev, state, 0);
 }
 
+#ifdef CONFIG_PM
 /**
  * e1000e_disable_aspm_locked   Disable ASPM states.
  * @pdev: pointer to PCI device struct
@@ -6452,7 +6453,6 @@ static void e1000e_disable_aspm_locked(struct pci_dev *pdev, u16 state)
 	__e1000e_disable_aspm(pdev, state, 1);
 }
 
-#ifdef CONFIG_PM
 static int __e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-- 
2.1.0
