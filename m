From: Dave Hansen <dave@sr71.net>
Subject: [PATCH] e1000: fix e1000e_disable_aspm_locked() warning
Date: Mon, 31 Aug 2015 14:26:41 -0700
Message-ID: <20150831212641.FA5D579A@viggo.jf.intel.com>
Cc: dave.hansen@linux.intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dave@sr71.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

I have a .config with CONFIG_PM disabled.  I get the following whenever
compiling the e1000 driver:

...net/ethernet/intel/e1000e/netdev.c:6450:13: warning: 'e1000e_disable_aspm_locked' defined but not used [-Wunused-function]
 static void e1000e_disable_aspm_locked(struct pci_dev *pdev, u16 state)

Looks like we just need to move e1000e_disable_aspm_locked() to
be underneath the CONFIG_PM #ifdef.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com> (supporter:INTEL ETHERNET DRIVERS)
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com> (reviewer)
Cc: Shannon Nelson <shannon.nelson@intel.com> (reviewer)
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com> (reviewer)
Cc: Don Skidmore <donald.c.skidmore@intel.com> (reviewer)
Cc: Matthew Vick <matthew.vick@intel.com> (reviewer)
Cc: John Ronciak <john.ronciak@intel.com> (reviewer)
Cc: Mitch Williams <mitch.a.williams@intel.com> (reviewer)
Cc: intel-wired-lan@lists.osuosl.org (open list:INTEL ETHERNET DRIVERS)
Cc: netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
Cc: linux-kernel@vger.kernel.org (open list)
---

 b/drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ethernet/intel/e1000e/netdev.c~fix-e1000-warning drivers/net/ethernet/intel/e1000e/netdev.c
--- a/drivers/net/ethernet/intel/e1000e/netdev.c~fix-e1000-warning	2015-08-31 14:19:11.520115321 -0700
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c	2015-08-31 14:19:11.525115549 -0700
@@ -6439,6 +6439,7 @@ static void e1000e_disable_aspm(struct p
 	__e1000e_disable_aspm(pdev, state, 0);
 }
 
+#ifdef CONFIG_PM
 /**
  * e1000e_disable_aspm_locked   Disable ASPM states.
  * @pdev: pointer to PCI device struct
@@ -6452,7 +6453,6 @@ static void e1000e_disable_aspm_locked(s
 	__e1000e_disable_aspm(pdev, state, 1);
 }
 
-#ifdef CONFIG_PM
 static int __e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
_
