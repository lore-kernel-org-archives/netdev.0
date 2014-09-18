From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates 2014-09-18
Date: Thu, 18 Sep 2014 05:26:50 -0700
Message-ID: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751080AbaIRM1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Ethan Zhao cleans up ixgbe and ixgbevf by removing bd_number from the
adapter struct because it is not longer useful.

Mark fixes ixgbe where if a hardware transmit timestamp is requested,
an uninitialized workqueue entry may be scheduled.  Added a check for
a PTP clock to avoid that.

Jacob provides a number of cleanups for ixgbe.  Since we may call
ixgbe_acquire_msix_vectors() prior to registering our netdevice, we
should not use the netdevice specific printk and use e_dev_warn()
instead.  Similar to how ixgbevf handles acquiring MSI-X vectors, we
can return an error code instead of relying on the flag being set.
This makes it more clear that we have failed to setup MSI-X mode and
will make it easier to consolidate MSI-X related code into a single
function.  In the case of disabling DCB, it is not an error since we
still can function, we just have to let the user know.  So use
e_dev_warn() instead of e_err().  Added warnings for other features
that are disabled when we are without MSI-X support.  Cleanup flags
that are no longer used or needed.

The following are changes since commit bf3c228d36c6b3c90074f928e84e318621969cc6:
  net: fec: fix build error at m68k platform
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Ethan Zhao (2):
  ixgbevf: remove useless bd_number from struct ixgbevf_adapter
  ixgbe: remove useless bd_number from adapter struct

Jacob Keller (8):
  ixgbe: use e_dev_warn instead of netif_printk
  ixgbe: return integer from ixgbe_acquire_msix_vectors
  ixgbe: move msix_entries allocation into ixgbe_acquire_msix_vectors
  ixgbe: determine vector count inside ixgbe_acquire_msix_vectors
  ixgbe: use e_dev_warn instead of e_err for displaying warning
  ixgbe: use e_dev_warn instead of netif_printk
  ixgbe: add warnings for other disabled features without MSI-X support
  ixgbe: remove IXGBE_FLAG_MSI(X)_CAPABLE flags

Mark Rustad (1):
  ixgbe: Do not schedule an uninitialized workqueue entry

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      | 151 +++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  11 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   1 -
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 -
 5 files changed, 83 insertions(+), 88 deletions(-)

-- 
1.9.3
