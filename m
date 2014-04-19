From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/7][pull request] Intel Wired LAN Driver Updates
Date: Fri, 18 Apr 2014 18:59:20 -0700
Message-ID: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56433 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429AbaDSB7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2014 21:59:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igb, ixgbe and i40e.

Most notably are Jakub's patches to clean up the Rx time stamping
code for ixgbe and the fix up of debug messages with proper termination.

Jesse's i40e patch fixes an issue reported by Eric Dumazet that the
i40e driver was allowing the hardware to replicate the PSH flag on
all segments of a TSO operation.  With this fix, we are now configuring
the CWR bit to only be set in the first packet of a TSO and we
enable TSO_ECN in order to advertise to the stack that we do the right
thing on the wire.

The following are changes since commit b14878ccb7fac0242db82720b784ab62c467c0dc:
  net: sctp: cache auth_enable per endpoint
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Francois Romieu (1):
  i40e: remove open-coded skb_cow_head

Hiroaki SHIMODA (1):
  e1000e: Enclose e1000e_pm_thaw() with CONFIG_PM_SLEEP

Jakub Kicinski (2):
  ixgbe: clean up Rx time stamping code
  e1000e/igb/ixgbe/i40e: fix message terminations

Jesse Brandeburg (1):
  i40e: fix TCP flag replication for hardware offload

Todd Fujinaka (1):
  igb: fix stats for i210 rx_fifo_errors

Vlad Yasevich (1):
  e1000e: Correctly include VLAN_HLEN when changing interface MTU

 drivers/net/ethernet/intel/e1000e/netdev.c      |  6 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c     |  9 ++++++
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c      |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 22 +++++++-------
 drivers/net/ethernet/intel/igb/e1000_i210.c     |  2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c      | 13 ++++----
 drivers/net/ethernet/intel/igb/igb_main.c       |  4 ++-
 drivers/net/ethernet/intel/igb/igb_ptp.c        |  4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        | 21 ++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    |  6 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c    | 40 ++++++++-----------------
 14 files changed, 59 insertions(+), 79 deletions(-)

-- 
1.9.0
