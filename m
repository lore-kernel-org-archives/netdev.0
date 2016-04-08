From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/18][pull request] 10GbE Intel Wired LAN Driver Updates 2016-04-07
Date: Thu,  7 Apr 2016 20:20:55 -0700
Message-ID: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63152 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbcDHDVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

This entire series (except for one patch from Alex) comes from Mark and
is mainly to add support for our new MAC (x550em_a).

So let's get Alex's patch out of the way first before we cover Mark's
many changes.  Alex does his enable bulk free in transmit cleanup for
ixgbe and ixgbevf, like his has done for all of our other drivers.

First Mark cleans up registers that were not being used, so do some
house cleaning.  Then to avoid casting lan_id and func fields, just
make them u8 since they only hold small values anyways.  Found and
fixed an issue where on read operations it could be possible to
modify locations beyond the length passed in, so change the check
to round up in the same way.  Cleaned up the interface for issuing
firmware commands to use a void * instead of a u32 * which eliminates
a number of casts.  Added support for the new MAC and provided method
pointers and use them to access IOSF-attached devices, since the
new MAC will also need a new access method.  Added support for SFPs
with an external retimer and for an SGMII backplane interface.

The following are changes since commit 889750bd2e08a94d52a116056d462b3a8e5616a7:
  Merge branch 'tipc-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (1):
  ixgbe/ixgbevf: Add support for bulk free in Tx cleanup & cleanup
    boolean logic

Mark Rustad (17):
  ixgbe: Delete some unused register definitions
  ixgbe: Change the lan_id and func fields to a u8 to avoid casts
  ixgbe: Correct length check for round up
  ixgbe: Clean up interface for firmware commands
  ixgbe: Take manageability semaphore for firmware commands
  ixgbe: Add support for single-port X550 device
  ixgbe: Add definitions for x550em_a 10G MAC
  ixgbe: Use method pointer to access IOSF devices
  ixgbe: Add support for x550em_a 10G MAC type
  ixgbe: Use new methods for PHY access
  ixgbe: Read and set instance id
  ixgbe: Read and parse NW_MNG_IF_SEL register
  ixgbe: Introduce function to control MDIO speed
  ixgbe: Add support for SFPs with retimer
  ixgbe: Add support for SGMII backplane interface
  ixgbe: Add KR backplane support for x550em_a
  ixgbe: Bump version number

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |  83 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c      |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |   9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  63 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c      |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c      |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     | 101 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     | 591 ++++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  14 +-
 14 files changed, 786 insertions(+), 106 deletions(-)

-- 
2.5.5
