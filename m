From: Ethan Zhao <ethan.zhao@oracle.com>
Subject: [PATCH 2/4] xen-pciback: use PCI VFs assignment
	helper functions
Date: Fri, 11 Jul 2014 08:47:20 +0800
Message-ID: <1405039642-23519-2-git-send-email-ethan.zhao@oracle.com>
References: <1405039642-23519-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.zhao@oracle.com>, linux.nics@intel.com,
	kvm@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-pci@vger.kernel.org, vaughan.cao@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ethan.kernel@gmail.com
To: bhelgaas@google.com, konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, gleb@kernel.org, pbonzini@redhat.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1405039642-23519-1-git-send-email-ethan.zhao@oracle.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

New VFs reference counter mechanism and VFs assignment helper functions are introduced to
PCI SRIOV, use them instead of manipulating device flag directly.

Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
---
 drivers/xen/xen-pciback/pci_stub.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/xen-pciback/pci_stub.c b/drivers/xen/xen-pciback/pci_stub.c
index 62fcd48..1d7b747 100644
--- a/drivers/xen/xen-pciback/pci_stub.c
+++ b/drivers/xen/xen-pciback/pci_stub.c
@@ -133,7 +133,7 @@ static void pcistub_device_release(struct kref *kref)
 	xen_pcibk_config_free_dyn_fields(dev);
 	xen_pcibk_config_free_dev(dev);
 
-	dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
+	pci_sriov_deassign_device(dev);
 	pci_dev_put(dev);
 
 	kfree(psdev);
@@ -404,7 +404,7 @@ static int pcistub_init_device(struct pci_dev *dev)
 	dev_dbg(&dev->dev, "reset device\n");
 	xen_pcibk_reset_device(dev);
 
-	dev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
+	pci_sriov_assign_device(dev);
 	return 0;
 
 config_release:
-- 
1.7.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
