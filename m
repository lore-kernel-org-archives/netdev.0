From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] 10GbE Intel Wired LAN Driver Updates 2015-12-12
Date: Sat, 12 Dec 2015 03:14:38 -0800
Message-ID: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14272 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbbLLLO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 06:14:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

Alex Duyck provides almost off of the changes in this series.  First, add a
check to make sure mac_table was actually allocated and is not NULL to
ensure we do not get a NULL pointer dereference further down the line.
Fixed SR-IOV VLAN pool configuration since the code for checking the PF bit
in ixgbe_set_vf_vlan_msg() was using the wrong offset.  Cleanup/simplify
the logic for setting the VFTA register by removing the number of
conditional checks needed.  Fixed a number of issues within the VLVF and
VLFB configuration by simplifying the code.  Added support for bypassing
the VLVF entry creation when the PF is adding a new VLAN.  Reduced the
complexity of the search function used for finding a VLVF entry associated
with a given VLAN ID.  Added support for VLAN promiscuous with SR-IOV
enabled by setting all the bits in the VFTA and all of the VLVF bits
associated with teh pool belonging to the PF, in addition to cleaning up
those same bits in the event of promiscuous mode being disabled.  Fixed
and issue where we ran the risk of leaking an address into pool 0 which
really belongs to VF 0 when SR-IOV is enabled.

Emil fixes an issue with some X550 devices which can connect at 2.5Gbps,
but only with certain link partners during fail-over, so to avoid
confusion, we do not report it as supported.

The following are changes since commit 9ad321b0b6de666814e3950c963387d116bfe3d1:
  Merge branch 'mlx5-flow-steering'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (11):
  ixgbe: Return error on failure to allocate mac_table
  ixgbe: Fix SR-IOV VLAN pool configuration
  ixgbe: Simplify definitions for regidx and bit in set_vfta
  ixgbe: Reduce VT code indent in set_vfta by introducing jump label
  ixgbe: Simplify configuration of setting VLVF and VLVFB
  ixgbe: Add support for adding/removing VLAN on PF bypassing the VLVF
  ixgbe: Reorder search to work from the top down instead of bottom up
  ixgbe: Add support for VLAN promiscuous with SR-IOV
  ixgbe: Fix VLAN promisc in relation to SR-IOV
  ixgbe: Clear stale pool mappings
  ixgbe: Clean stale VLANs when changing port VLAN or resetting

Emil Tantilov (1):
  ixgbe: do not report 2.5 Gbps as supported

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |  10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 236 ++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 194 +++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   | 187 ++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |  10 +-
 10 files changed, 415 insertions(+), 235 deletions(-)

-- 
2.5.0
