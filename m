From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Fri, 12 Apr 2013 04:24:15 -0700
Message-ID: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11922 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752851Ab3DLLYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 07:24:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

My previous pull request had a mix of ixgbe and igb patches, and
while Akeem works on the changes requested on the igb patches, I
going ahead and re-submitting the originally submitted ixgbe patches
with several other ixgbe patches.

Alex provides a performance improvement with the enabling the use of
build_skb for instances where jumbo frames are disabled.  In addition,
Alex provides a fix where we were incorrectly checking the entire frag_off
field when we only wanted the fragment offset.  Lastly, he cleans up
the check for PAGE_SIZE, since the default configuration allocates 32K
for all buffers.

Emil provides a change to the calculation of eerd so that it is consistent
between the read and write functions by using | instead of +.

Jacob adds support for displaying PCIe Gen3 link speed, which was
previously missing from the ixgbe driver.  He also provides a patch
to clean up ixgbe_get_bus_info_generic to call some conversion
functions, which are used also in another patch provided by Jacob.
Jacob modifies the driver to enable certain devices (which have an
internal switch) to read from the physical slot rather than reading
data from the internal switch.  Lastly, Jacob adds a function which
enables the ixgbe driver to walk up the PCI bus for the device and
query the PCI config space for the bus width at each point.


Don provides a couple of fixes (which are more appropriate for net-next),
one of which resolves an issue where ixgbe was only turning on the laser
when the adapter was up which caused issues for those who wanted to
access the MNG firmware while the port was in a down state.  The other
fix is for WoL when currently linked at 1G.  Lastly Don bumps the driver
version keep the in-kernel driver up to date with the current functionality.

The following are changes since commit 6c6779856a294649dbb468ef46e893e80b0d72ad:
  Revert "netprio_cgroup: make local table static"
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (3):
  ixgbe: Support using build_skb in the case that jumbo frames are
    disabled
  ixgbe: Mask off check of frag_off as we only want fragment offset
  ixgbe: Drop check for PAGE_SIZE from ixgbe_xmit_frame_ring

Don Skidmore (3):
  ixgbe: fix MNG FW support when adapter not up
  ixgbe: Fix 1G link WoL
  ixgbe: bump version number

Emil Tantilov (1):
  ixgbe: don't do arithmetic operations on bitmasks

Jacob Keller (4):
  ixgbe: Enable support for recognizing PCI-e Gen3 link speed
  ixgbe: create conversion functions from link_status to bus/speed
  ixgbe: enable devices with internal switch to read pci parent
  ixgbe: walk pci-e bus to find minimum width

 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |   7 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |  51 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  63 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 289 ++++++++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |  13 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |   1 +
 8 files changed, 343 insertions(+), 84 deletions(-)

-- 
1.7.11.7
