From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] Intel Wired LAN Driver Updates 2015-10-23
Date: Fri, 23 Oct 2015 06:17:42 -0700
Message-ID: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com, thomas.long@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13278 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbbJWNSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf, if_link, ixgbe and ixgbevf.

Anjali adds a workaround to drop any flow control frames from being
transmitted from any VSI, so that a malicious VF cannot send flow control
or PFC packets out on the wire.  Also fixed a bug in debugfs by grabbing
the filter list lock before adding or deleting a filter.

Akeem fixes an issue where we were unconditionally returning VEB bridge
mode before allowing LB in the add VSI routine, resolve by checking if
the bridge is actually in VEB mode first.

Mitch fixed an issue where the incorrect structure was being used for
VLAN filter list, which meant the VLAN filter list did not get
processed correctly and VLAN filters would not be re-enabled after any
kind of reset.

Helin fixed a problem of possibly getting inconsistent flow control
status after a PF reset.  The issue was requested_mode was being set
with a default value during probe, but the hardware state could be a
different value from this mode.

Carolyn fixed a problem where the driver output of the OEM version
string varied from the other tools.

Jean Sacren fixes up kernel documentation by fixing function header
comments to match actual variables used in the functions.  Also
cleaned up variable initialization, when the variable would be
over-written immediately.

Hiroshi Shimanoto provides three patches to add "trusted" VF by adding
netlink directives and an NDO entry.  Then implement these new controls
in ixgbe and ixgbevf.  This series has gone through several iterations
to address all the suggested community changes and concerns.

The following are changes since commit 7b1311807f3d3eb8bef3ccc53127838b3bea3771:
  ipv4: implement support for NOPREFIXROUTE ifa flag for ipv4 address
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Akeem G Abodunrin (2):
  i40e: Fix VEB/VEPA bridge mode mismatch issue
  i40e: Disable VEB bridge mode with SR-IOV failure

Andy Shevchenko (1):
  i40e: re-use %*ph specifier to hexdump a data

Anjali Singhai Jain (2):
  i40e/i40evf: Add a workaround to drop all flow control frames
  i40e: fix a bug in debugfs with add/del macaddr

Carolyn Wyborny (1):
  i40e: Fix an incorrect OEM version string

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e to 1.3.46 and i40evf to 1.3.33

Helin Zhang (1):
  i40e: fix inconsistent statuses after a PF reset

Hiroshi Shimamoto (3):
  if_link: Add control trust VF
  ixgbe: Add new ndo to trust VF
  ixgbe, ixgbevf: Add new mbox API xcast mode

Jean Sacren (5):
  i40evf: add missing kernel-doc argument
  i40e: add missing kernel-doc argument
  i40evf: clean up local variable initialization
  i40e: clean up local variable initialization
  i40e: fix unconditional execution of cpu_to_le16()

Mitch Williams (1):
  i40evf: use correct struct for list manipulation

 drivers/net/ethernet/intel/i40e/i40e.h             | 17 +++-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 44 ++++++----
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  4 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 56 ++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  9 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  2 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 22 +----
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  2 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 17 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |  8 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       |  2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     | 96 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |  6 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  8 ++
 drivers/net/ethernet/intel/ixgbevf/mbx.h           |  2 +
 drivers/net/ethernet/intel/ixgbevf/vf.c            | 41 +++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h            |  1 +
 include/linux/if_link.h                            |  1 +
 include/linux/netdevice.h                          |  3 +
 include/uapi/linux/if_link.h                       |  6 ++
 net/core/rtnetlink.c                               | 24 +++++-
 25 files changed, 318 insertions(+), 59 deletions(-)

-- 
2.4.3
