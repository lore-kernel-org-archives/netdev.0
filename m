From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 0/9][pull request] Intel Wired LAN Driver Updates
Date: Wed, 17 Apr 2013 23:33:52 -0700
Message-ID: <1366266841-12466-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18006 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab3DRGeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 02:34:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

v2- Dropped the following 2 patches from the series:
 ixgbe: Support using build_skb in the case that jumbo frames are disabled
 ixgbe: walk pci-e bus to find minimum width

Ben Hutchings found a bug with Alex's patch, so that patch was dropped
permanently.  Jacob's "walk PCIe bus" patch is being re-worked for
a more generic solution so that other drivers can benefit.

In the remaining patches...
Alex provides a fix where we were incorrectly checking the entire frag_off
field when we only wanted the fragment offset.  Alex also cleans up
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
data from the internal switch.

Don provides a couple of fixes (which are more appropriate for net-next),
one of which resolves an issue where ixgbe was only turning on the laser
when the adapter was up which caused issues for those who wanted to
access the MNG firmware while the port was in a down state.  The other
fix is for WoL when currently linked at 1G.  Lastly Don bumps the driver
version keep the in-kernel driver up to date with the current functionality.

The following are changes since commit 2551c405e886c4ce4732bedaa8559a110a6f373f:
  Merge branch 'tipc-ipoib'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Mask off check of frag_off as we only want fragment offset
  ixgbe: Drop check for PAGE_SIZE from ixgbe_xmit_frame_ring

Don Skidmore (3):
  ixgbe: fix MNG FW support when adapter not up
  ixgbe: Fix 1G link WoL
  ixgbe: bump version number

Emil Tantilov (1):
  ixgbe: don't do arithmetic operations on bitmasks

Jacob Keller (3):
  ixgbe: Enable support for recognizing PCI-e Gen3 link speed
  ixgbe: create conversion functions from link_status to bus/speed
  ixgbe: enable devices with internal switch to read pci parent

 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  | 51 +++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 63 ++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |  2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 76 +++++++++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   | 13 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |  1 +
 7 files changed, 162 insertions(+), 45 deletions(-)

-- 
1.7.11.7
