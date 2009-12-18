From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH v2 1/6] pci: Add pci_num_vf function
Date: Thu, 17 Dec 2009 17:33:53 -0800
Message-ID: <20091218013329.4510.25937.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:34492
	"EHLO QMTA12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751118AbZLRBeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 20:34:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add and export pci_num_vf to allow other subsystems to determine how many
virtual function devices are associated with an SR-IOV physical function
device.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/pci/iov.c   |   15 +++++++++++++++
 include/linux/pci.h |    5 +++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index b2a448e..52ee6d3 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -706,6 +706,21 @@ irqreturn_t pci_sriov_migration(struct pci_dev *dev)
 }
 EXPORT_SYMBOL_GPL(pci_sriov_migration);
 
+/**
+ * pci_num_vf - return number of VFs associated with a PF device_release_driver
+ * @dev: the PCI device
+ *
+ * Returns number of VFs, or 0 if SR-IOV is not enabled.
+ */
+int pci_num_vf(struct pci_dev *dev)
+{
+	if (!dev->is_physfn)
+		return 0;
+	else
+		return dev->sriov->nr_virtfn;
+}
+EXPORT_SYMBOL_GPL(pci_num_vf);
+
 static int ats_alloc_one(struct pci_dev *dev, int ps)
 {
 	int pos;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 04771b9..c44d6e0 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1282,6 +1282,7 @@ void __iomem *pci_ioremap_bar(struct pci_dev *pdev, int bar);
 extern int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);
 extern void pci_disable_sriov(struct pci_dev *dev);
 extern irqreturn_t pci_sriov_migration(struct pci_dev *dev);
+extern int pci_num_vf(struct pci_dev *dev);
 #else
 static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
 {
@@ -1294,6 +1295,10 @@ static inline irqreturn_t pci_sriov_migration(struct pci_dev *dev)
 {
 	return IRQ_NONE;
 }
+static inline int pci_num_vf(struct pci_dev *dev)
+{
+	return 0;
+}
 #endif
 
 #if defined(CONFIG_HOTPLUG_PCI) || defined(CONFIG_HOTPLUG_PCI_MODULE)

