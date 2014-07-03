From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2014-07-02
Date: Wed,  2 Jul 2014 19:40:19 -0700
Message-ID: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40752 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbaGCClE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Anjali fixes a possible race where we were trying to free the dummy packet
buffer in the function that created it, so cleanup the dummy packet buffer
in i40e_clean_tx_ring() instead.  Also fixes an issue where the filter
program routine was not checking if there were descriptors available for
programming a filter.

Mitch fixes unnecessary delays when sending the admin queue commands by
moving a declaration up one level so we do not dereference it out of scope.
Fixes an issue with the VF where if the admin queue interrupts get lost for
some reason, the VF communication will stall as the VFs have no way of
reaching the PF.  To alleviate this condition, go ahead and check the ARQ
every time we run the service task.  Updates i40evf to allow the watchdog
to fire vector 0 via software, which makes the driver tolerant of dropped
interrupts on that vector.

Paul fixes a shifted '1' to be unsigned to avoid shifting a signed integer.

Jesse disables TPH by default since it is currently not enabled in the
current hardware.  Also finishes the i40e implementation of get_settings
for ethtool.

Catherine adds a new variable (hw.phy.link_info.an_enabled) to track whether
auto-negotiation is enabled, along with the functionality to update the
variable.  Adds the functionality to set the requested flow control mode.
Adds i40e implementation of setpauseparam and set_settings to ethtool.

The following are changes since commit bd4578bc84a8c8a390cf6002539e75447e78e935:
  drivers/net/hyperv/netvsc.c: remove unnecessary null test before kfree
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (2):
  i40e/i40evf: Do not free the dummy packet buffer synchronously
  i40e: Fix a boundary condition and turning off of ntuple

Catherine Sullivan (5):
  i40e/i40evf: Add new HW link info variable an_enabled and function
    update_link_info
  i40e/i40evf: Add set_fc and init of FC settings
  i40e: Add set_pauseparam to ethtool
  i40e: Implement set_settings for ethtool
  i40e/i40evf: Bump i40e to 0.4.21 and i40evf to 0.9.40

Jesse Brandeburg (3):
  i40e: disable TPH
  i40e: Finish implementation of ethtool get settings
  i40e: move nway reset

Mitch Williams (3):
  i40evf: don't violate scope
  i40e: tolerate lost interrupts
  i40evf: invite vector 0 to the interrupt party

Paul M Stillwell Jr (1):
  i40e/i40evf: Force a shifted '1' to be unsigned

 drivers/net/ethernet/intel/i40e/i40e_common.c      | 200 ++++++++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 422 +++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 107 ++----
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  10 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 109 +++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   9 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   4 -
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h       |   4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   9 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   9 +-
 15 files changed, 731 insertions(+), 176 deletions(-)

-- 
1.9.3
