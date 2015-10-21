From: Lan Tianyu <tianyu.lan@intel.com>
Subject: [RFC Patch 01/12] PCI: Add virtfn_index for struct
	pci_device
Date: Thu, 22 Oct 2015 00:37:33 +0800
Message-ID: <1445445464-5056-2-git-send-email-tianyu.lan@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Cc: Lan Tianyu <tianyu.lan@intel.com>
To: bhelgaas@google.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Add "virtfn_index" member in the struct pci_device to record VF sequence
of PF. This will be used in the VF sysfs node handle.

Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
---
 drivers/pci/iov.c   | 1 +
 include/linux/pci.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index ee0ebff..065b6bb 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -136,6 +136,7 @@ static int virtfn_add(struct pci_dev *dev, int id, int reset)
 	virtfn->physfn = pci_dev_get(dev);
 	virtfn->is_virtfn = 1;
 	virtfn->multifunction = 0;
+	virtfn->virtfn_index = id;
 
 	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
 		res = &dev->resource[i + PCI_IOV_RESOURCES];
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 353db8d..85c5531 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -356,6 +356,7 @@ struct pci_dev {
 	unsigned int	io_window_1k:1;	/* Intel P2P bridge 1K I/O windows */
 	unsigned int	irq_managed:1;
 	pci_dev_flags_t dev_flags;
+	unsigned int	virtfn_index;
 	atomic_t	enable_cnt;	/* pci_enable_device has been called */
 
 	u32		saved_config_space[16]; /* config space saved at suspend time */
-- 
1.8.4.rc0.1.g8f6a3e5.dirty
