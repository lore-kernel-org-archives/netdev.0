From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/18][pull request] Intel Wired LAN Driver Updates 2015-06-09
Date: Tue,  9 Jun 2015 18:10:11 -0700
Message-ID: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59836 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932532AbbFJBKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe only.

The series adds additional support for x550 support, such as WoL and
auto-negotiation of flow control.  Adds new PHY support (external PHY)
for x550, as well as the new methods/functions needed to support the new
PHY's.  Fixed a bug found in code inspection, where a check was missed
when clearing counters for x550.  Also fixed the init code flow for copper
x550 devices.

The following are changes since commit 6651ee070b3124fe9b9db383e3a895a0e4aded65:
  s390/bpf: implement bpf_tail_call() helper
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Don Skidmore (18):
  ixgbe: add array of MAC type dependent values
  ixgbe: add support for WoL and autoneg FC for some X550 devices
  ixgbe: add define for X557 PHY ID
  ixgbe: Add a PHY power state method
  ixgbe: Restore ESDP settings after MAC reset
  ixgbe: add X550 support for external PHY and forced 1G/10G support
  ixgbe: Add reset for X550 device
  ixgbe: Add const string for overheat message
  ixgbe: add support for interrupts from X550 external PHY
  ixgbe: fix issue with sfp events with new X550 devices
  ixgbe: fix bug in not clearing counters for X550 devices
  ixgbe: fix X550 devices init flow
  ixgbe: fix X550 PHY function pointers
  ixgbe: Add support for another X550 device.
  ixgbe: add link check for X550 copper
  ixgbe: Set lan_id before using I2C
  ixgbe: fix X550 default set_phy_power method
  ixgbe: Remember to write ixfi changes after modifying

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |  63 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |   2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 154 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |  87 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h     |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    | 272 ++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |  42 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    | 810 ++++++++++++++++-------
 12 files changed, 1044 insertions(+), 405 deletions(-)

-- 
2.4.2
