From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Tue, 10 Dec 2013 02:22:29 -0800
Message-ID: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215Ab3LJKXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:23:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, igb, ixgbe and ixgbevf.

Shannon provides a couple of i40e patches, first restricts the ethtool
diag test messages by using netif_info() macro to when the hardware
bit is enabled in the message level netdev message mask.  Second
provides a fix for when there is an out-of-range descriptor request.

Kamil provides a fix for i40e by updating the loopback enum types and
add information about the current loopback mode to data returned from
get_link_info().

Jesse provides a fix for i40e define name that was being mis-used.
I40E_ITR_NONE was being used as an ITRN register index by accident
because it was easily associated with the i40e Rx ITR and friends
defines, when it should be associated with the DYN_CTL register sets.

Jacob provides an update for ixgbevf Kconfig description since the VF
driver supports more than just the 82599 device.

Don and Alex provide a cleanup patch for ixgbe to make it where head,
tail, next to clean and next to use are all reset in a single function
for both Tx and Rx path.  Before, the code for this was spread out over
several areas which made it difficult to track what the values were for
each of the values.

Carolyn provides two igb patches to add a media switching feature for
i354 PHY's and new Media Auto Sense for 82580 devices only.

Aaron Sierra provides a fix for igb to resolve an issue with the 64-bit
PCI addresses being truncated because the return values of
pci_resource_start() and pci_resouce_end() were being cast to unsigned
long.

Guenter Roeck provides two igb patches, first simplifies the code by
attaching the hwmon sysfs attributes to hwmon device instead of the
PCI device.  Second fixes the temperature sensor attribute index by
setting it to 1 instead of 0 (per hwmon ABI).

The following are changes since commit 5824d2d16d39a9c57aa3bacf955fbd0c2134061f:
  bgmac: connect to PHY and make use of PHY device
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Aaron Sierra (1):
  igb: Support ports mapped in 64-bit PCI space

Carolyn Wyborny (2):
  igb: Add media switching feature for i354 PHY's
  igb: Add new feature Media Auto Sense for 82580 devices only

Catherine Sullivan (1):
  i40e: Bump version number

Don Skidmore (1):
  ixgbe: Focus config of head, tail ntc, and ntu all into a single
    function

Guenter Roeck (2):
  igb: Convert to use devm_hwmon_device_register_with_groups
  igb: Start temperature sensor attribute index with 1

Jacob Keller (1):
  ixgbevf: update Kconfig description

Jesse Brandeburg (1):
  i40e: remove and fix confusing define name

Kamil Krawczyk (1):
  i40e: loopback info and set loopback fix

Shannon Nelson (2):
  i40e: restrict diag test messages
  i40e: complain about out-of-range descriptor request

 drivers/net/ethernet/intel/Kconfig                |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c     |   1 +
 drivers/net/ethernet/intel/i40e/i40e_diag.h       |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    |  41 +++--
 drivers/net/ethernet/intel/i40e/i40e_main.c       |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h       |  21 ++-
 drivers/net/ethernet/intel/i40e/i40e_type.h       |   1 +
 drivers/net/ethernet/intel/igb/e1000_82575.c      |  89 +++++++++
 drivers/net/ethernet/intel/igb/e1000_defines.h    |  16 ++
 drivers/net/ethernet/intel/igb/e1000_hw.h         |   3 +
 drivers/net/ethernet/intel/igb/igb.h              |  19 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c      |   4 +
 drivers/net/ethernet/intel/igb/igb_hwmon.c        | 108 ++++++-----
 drivers/net/ethernet/intel/igb/igb_main.c         | 209 +++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  55 ++----
 16 files changed, 453 insertions(+), 136 deletions(-)

-- 
1.8.3.1
