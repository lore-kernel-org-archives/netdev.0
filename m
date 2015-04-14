From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/25][pull request] Intel Wired LAN Driver Updates 2015-04-14
Date: Tue, 14 Apr 2015 16:50:46 -0700
Message-ID: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	alexander.h.duyck@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567AbbDNXvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Fixed transmit statistics which was actually using values from the
receive ring, instead of the transmit ring.  Fixed up spelling mistakes
in code comments and resolved unused argument warnings.  Added support
for netconsole.  Fixed up statistic reporting so that we are only
reporting from actual queues as well as display PF only stats for
just the PF and not the VF.  Also fixed an issue that when returning
virtualization queues from the VF back to the PF, we were retaining
the VF rate limiter.

Fixed up the driver to use a separate workqueue, which helps reduce
and stabilize latency between scheduling the work in our interrupt and
actually performing the work.

Fixed a bug where the VF tried to set a multicast address before
requesting the required xcast mode.

Fix VF multicast update since VFs were being improperly added to the
switch's mutlicast group.  The error stems from the fact that incorrect
arguments were passed to the update_mc_addr().

Thanks to Alex Duyck for the extensive review.

The following are changes since commit 87ffabb1f055e14e7d171c6599539a154d647904:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Jeff Kirsher (25):
  fm10k: Corrected an error in Tx statistics
  fm10k: Remove redundant rx_errors in ethtool
  fm10k: Correct spelling mistake
  fm10k: Have the VF get the default VLAN during init
  fm10k: Add netconsole support
  fm10k: fix unused warnings
  fm10k: allow creation of VLAN on default vid
  fm10k: only show actual queues, not the maximum in hardware
  fm10k: use hw->mac.max_queues for stats
  fm10k: separate PF only stats so that VF does not display them
  fm10k: remove extraneous "Reset interface" message
  fm10k: only increment tx_timeout_count in Tx hang path
  fm10k: expose tx_timeout_count as an ethtool stat
  fm10k: Set PF queues to unlimited bandwidth during virtualization
  fm10k: use separate workqueue for fm10k driver
  fm10k: don't handle mailbox events in iov_event path and always
    process mailbox
  fm10k: comment next_vf_mbx flow
  fm10k: fix function header comment
  fm10k: start service timer on probe
  fm10k: update xcast mode before synchronizing multicast addresses
  fm10k: renamed mbx_tx_dropped to mbx_tx_oversized
  fm10k: reset head instead of calling update_max_size
  fm10k: mbx_update_max_size does not drop all oversized messages
  fm10k: corrected VF multicast update
  fm10k: Bump driver version to 0.15.2

 drivers/net/ethernet/intel/fm10k/fm10k.h         |  9 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c   |  6 +-
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c |  8 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 93 ++++++++++++++++--------
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     | 51 ++++---------
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 33 +++++----
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     | 34 ++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 37 +++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 61 +++++++++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 10 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     |  5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      |  6 +-
 12 files changed, 215 insertions(+), 138 deletions(-)

-- 
1.9.3
