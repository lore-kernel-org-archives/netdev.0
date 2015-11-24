From: Lan Tianyu <tianyu.lan@intel.com>
Subject: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for SRIOV NIC
Date: Tue, 24 Nov 2015 21:38:15 +0800
Message-ID: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
To: a.motakis@virtualopensystems.com, alex.williamson@redhat.com,
	b.reynal@virtualopensystems.com, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, gerlitz.or@gmail.com,
	mark.d.rustad@intel.com, mst@redhat.com, eric.auger@linaro.org,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com,
	tianyu.lan@intel.com, weiyang@linux.vnet.ibm.com, zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is to propose a solution of adding live migration
support for SRIOV NIC.

During migration, Qemu needs to let VF driver in the VM to know
migration start and end. Qemu adds faked PCI migration capability
to help to sync status between two sides during migration.

Qemu triggers VF's mailbox irq via sending MSIX msg when migration
status is changed. VF driver tells Qemu its mailbox vector index
via the new PCI capability. In some cases(NIC is suspended or closed),
VF mailbox irq is freed and VF driver can disable irq injecting via
new capability.

VF driver will put down nic before migration and put up again on
the target machine.

Lan Tianyu (3):
  VFIO: Add new ioctl cmd VFIO_GET_PCI_CAP_INFO
  PCI: Add macros for faked PCI migration capability
  Ixgbevf: Add migration support for ixgbevf driver

 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   5 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 102 ++++++++++++++++++++++
 drivers/vfio/pci/vfio_pci.c                       |  21 +++++
 drivers/vfio/pci/vfio_pci_config.c                |  38 ++++++--
 drivers/vfio/pci/vfio_pci_private.h               |   5 ++
 include/uapi/linux/pci_regs.h                     |  18 +++-
 include/uapi/linux/vfio.h                         |  12 +++
 7 files changed, 194 insertions(+), 7 deletions(-)

-- 
1.8.4.rc0.1.g8f6a3e5.dirty
