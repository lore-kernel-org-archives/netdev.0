From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates 2015-06-04
Date: Thu,  4 Jun 2015 20:27:01 -0700
Message-ID: <1433474824-5414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47765 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbbFED1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 23:27:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Anjali provides three fixes, first to resolve a Tx queue hang if mixed
size frags are passed to the driver while using TSO.  There was a corner
case where we needed to linearize but we were not.  Next fixes a bug in
the default configuration which prevented a software bridge loaded on the
PF interface from working correctly because broadcast packets are
incorrectly looped back.  Lastly fixes an NPAR bug when SRIOV is enabled,
where we need to be in VEB mode, not VEPA mode at probe.

The following are changes since commit 6e540309326188f769e03bb4c6dd8ff6752930c2:
  ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Anjali Singhai Jain (3):
  i40e/i40evf: Fix mixed size frags and linearization
  i40e: start up in VEPA mode by default
  i40e: Make sure to be in VEB mode if SRIOV is enabled at probe

 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  9 ++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 35 +++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 25 +++++++---------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 10 ++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 25 +++++++---------
 6 files changed, 70 insertions(+), 35 deletions(-)

-- 
2.1.0
