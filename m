From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 0/4] move pci_assivned_vfs() check (while disabling VFs) to pci sub-system
Date: Mon, 10 Nov 2014 17:23:26 +0530
Message-ID: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>, <linux.nics@intel.com>,
	<shahed.shaikh@qlogic.com>, <ddutile@redhat.com>
To: <linux-pci@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A user must not be allowed to disable VFs while they are already assigned to
a guest. This check is being made in each individual driver that implements
the sriov_configure PCI method.
This patch-set fixes this code duplication by moving this check from
drivers to the sriov_nuvfs_store() routine just before invoking
sriov_configure() when num_vfs is equal to 0.

Vasundhara Volam (4):
  pci: move pci_assivned_vfs() check while disabling VFs to pci
    sub-system
  bnx2x: remove pci_assigned_vfs() check while disabling VFs
  i40e: remove pci_assigned_vfs() check while disabling VFs
  qlcnic: remove pci_assigned_vfs() check while disabling VFs

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    7 +------
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   10 ----------
 drivers/pci/pci-sysfs.c                            |    5 +++++
 4 files changed, 7 insertions(+), 17 deletions(-)
