From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC net-next PATCH 0/4] Add new settings for ethtool
Date: Wed, 27 Jul 2011 15:17:44 -0700
Message-ID: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58331 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304Ab1G0WRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 18:17:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches implements several changes to the way SR-IOV
can be configured to allow for per port assignment of the number of
VFs.

In addition, patches 1/4 and 2/4 of this patch series adds a new flag
bit to the PCI device structure dev_flags that is used by the kvm
module to indicate when a PCI device is assigned to a guest virtual
machine (VM) and changes to the ixgbe driver to make use of this new
bit.  The advantage these first two patches provide is to prevent
destruction of virtual functions (VFs) by the physical function
(PF) driver when it is removed if the PF driver finds that any VFs
are still assigned to guest VMs.  This in turn prevents panics that
will result when the VF device disappears from the guest VM without
notification.

Patches 3/4 and 4/4 of this patch series implement new settings for
Ethtool that allow for reconfiguration of the number of VFs per PF
without resorting to use of the module parameter which is only capable
of setting a single number of VFs per PF, to set the number of VM
queues for devices that support it and an on/off switch for the
anti-spoofing feature.  A follow on patch for Ethtool that implements
these settings will be sent separately.

Patches 1/4 and 2/4 of this series could also be considered for
submission to the current net tree and also the stable tree since
they prevent catastrophic results when the PF driver is removed
while VFs are assigned to guest VMs.

---

Greg Rose (4):
      ixgbe: Add support for new ethtool settings
      ethtool: Add new set commands
      ixgbe: Reconfigure SR-IOV Init
      pci: Add flag indicating device has been assigned by KVM


 drivers/net/ixgbe/ixgbe.h         |    2 
 drivers/net/ixgbe/ixgbe_ethtool.c |   96 ++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |  109 ++------------------
 drivers/net/ixgbe/ixgbe_sriov.c   |  197 +++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_sriov.h   |    6 +
 drivers/net/ixgbe/ixgbe_type.h    |    4 +
 include/linux/ethtool.h           |   11 ++
 include/linux/pci.h               |    2 
 virt/kvm/assigned-dev.c           |    2 
 virt/kvm/iommu.c                  |    4 +
 10 files changed, 333 insertions(+), 100 deletions(-)

-- 
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
