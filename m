From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Driver Updates 2014-10-16
Date: Thu, 16 Oct 2014 02:36:23 -0700
Message-ID: <1413452187-2950-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44209 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbaJPJga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2014 05:36:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k and ixgbe.

Matthew provides two fixes for fm10k, first sets the flag to fetch the
host state before kicking off the service task that reads the host
state when bringing the interface up.  The second makes sure that we
release the mailbox lock after detecting an error and before we return
the error code.

Andy Zhou provides a compile fix for fm10k, when the driver is compiled
into the kernel and the VXLAN driver is compiled as a module.

Emil provides a fix for ixgbe to prevent against a panic by trying
to dereference a NULL pointer in ixgbe_ndo_set_vf_spoofchk().

The following are changes since commit 91269e390d062b526432f2ef1352b8df82e0e0bc:
  vxlan: using pskb_may_pull as early as possible
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Andy Zhou (1):
  fm10k: Add CONFIG_FM10K_VXLAN configuration option

Emil Tantilov (1):
  ixgbe: check for vfs outside of sriov_num_vfs before dereference

Matthew Vick (2):
  fm10k: Check the host state when bringing the interface up
  fm10k: Unlock mailbox on VLAN addition failures

 drivers/net/ethernet/intel/Kconfig              | 11 +++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 13 +++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |  3 +++
 4 files changed, 22 insertions(+), 6 deletions(-)

-- 
1.9.3
