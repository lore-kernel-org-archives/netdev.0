From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] Intel Wired LAN Driver Updates 2015-09-30
Date: Wed, 30 Sep 2015 05:52:24 -0700
Message-ID: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48753 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754899AbbI3Mwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Vasily Averin provides a couple of rtnl lock/unlock fixes for both i40e
and i40evf.

Shannon provides several updates and fixes, first fixes up a type clash
in i40e_aq_rc_to_posix(), where the error codes are signed values, so we
need to treat them as such.  Then fixes up a padding issue where an
extra byte is added in i40e_aqc_get_cee_dcb_cfg_v1_resp to directly
acknowledge the padding.  Updated i40e to keep debugfs register read
and writes from accessing outside of the io-remapped space.  Added
support and device id for another 20 GbE device.

Jesse fixes the transmit hand workaround code for ARM that was causing
Tx hangs to still occur occasionally when there really was no hang.  Then
fixed the receive dropped counter to show up in netstat interface.
Refactor the interrupt enable function since it was always making the
caller add the base_vector from the VSI struct which is already passed
to the function.  Fix kbuild warnings found in 0day build infrastructure
by adding a harmless cast to a dev_info(), also fix 32 bit build
warnings found by sparse.

Greg fixed a configuration error that results if a port VLAN is set
for a VF before the VF driver is loaded, so that when the VF driver is
loaded the port VLAN is ignored.

Mitch fixes the use of QOS field consistently in
i40e_ndo_set_vf_port_vlan().  Modified the init timing of the driver
to increase stability on load/unload and SR-IOV enable/disable cycles.

Anjali updates i40e to not collect VEB stats if they are disabled in the
hardware for performance reasons.

The following are changes since commit 4bf1b54f9df7ced4869f7dfd0bdf5eb22aa98447:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (1):
  i40e: Strip VEB stats if they are disabled in HW

Greg Rose (2):
  i40e: Fix a port VLAN configuration bug
  i40e: Remove useless message

Jesse Brandeburg (6):
  i40e/i40evf: fix Tx hang workaround code
  i40e: count drops in netstat interface
  i40e: refactor interrupt enable
  i40e: warn on double free
  i40e: fix kbuild warnings
  i40e: fix 32 bit build warnings

Mitch Williams (2):
  i40e: use QOS field consistently
  i40evf: tweak init timing

Shannon Nelson (4):
  i40e/i40evf: fix up type clash in i40e_aq_rc_to_posix conversion
  i40e: fixup padding issue in get_cee_dcb_cfg_v1_resp
  i40e: limit debugfs io ops
  i40e/i40evf: add new device id 1588

Vasily Averin (2):
  i40evf: missing rtnl_unlock in i40evf_resume()
  i40e: rtnl_lock called twice in i40e_pci_error_resume()

 drivers/net/ethernet/intel/i40e/i40e.h             |  4 ++-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |  9 +++--
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 13 +++++--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  6 +---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 12 +++----
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 10 ++++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 42 +++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 11 +++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        | 12 +++----
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  9 +++--
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |  9 +++--
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  3 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  7 ++--
 16 files changed, 87 insertions(+), 63 deletions(-)

-- 
2.4.3
