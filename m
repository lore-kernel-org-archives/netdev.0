From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Tue, 17 Dec 2013 22:44:28 -0800
Message-ID: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320Ab3LRGoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:44:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, ixgbevf, ixgbe and igb.

Don provides an ixgbevf patch to add DCB configuration into the queue
setup so that we won't have to allocate queues in a separate place when
enabling DCB.

Guenter Roeck provides 2 patches for ixgbe to simplify the code by
attaching hwmon sysfs attributes to hwmon device instead of PCI device.
Also fix an issues where the temperature sensor attribute index was
being started with the value 0 and not 1 as per the hwmon API.

Carolyn provides igb patches to fix queue allocation method to
accommodate changes during runtime.  This includes changing how the
driver initializes MSIx and checks for MSIx configuration to make it
easier to reconfigure the device when queue changes happen at runtime.

Neerav and Shannon fixes i40e debugfs commands that dump hex information
by using print_hex_dump().

Shannon provides several i40e fixes which include the prevention of
null pointer exception in the dump descriptor by checking that rings
were allocated before trying to reference them.  Fixed up a couple of
scanfs to accept various base numbers instead of silently requiring hex.

Anjali fixes up i40e where the incorrect defines were being used for
misc interrupts.

Alan Cox provides a fix for i40e where we assume that the resulting
buffer is zero terminated when we then re-use it.  The sscanf is limited
to 512 bytes but needs to be 511 to allow for a terminator.

Stephen Hemminger fixes i40e by making local functions static and removes
unused code (i40e_aq_add/remove_vlan() functions).

The following are changes since commit 02d5cb5bb20b9d34db20860aad1891cd9b8e81d5:
  qeth: Accurate ethtool output
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alan Cox (1):
  i40e: Fix off by one in i40e_dbg_command_write

Anjali Singhai Jain (1):
  i40e: Fix wrong mask bits being used in misc interrupt

Carolyn Wyborny (2):
  igb: Fix queue allocation method to accomodate changing during runtime
  igb: Change to use statically allocated array for MSIx entries

Catherine Sullivan (1):
  i40e: Bump version number

Don Skidmore (1):
  ixgbevf: add DCB configuration into queue setup

Guenter Roeck (2):
  ixgbe: Convert to use devm_hwmon_device_register_with_groups
  ixgbe: Start temperature sensor attribute index with 1

Neerav Parikh (1):
  i40e: Fix dump output from debugfs calls

Shannon Nelson (4):
  i40e: prevent null pointer exception in dump descriptor
  i40e: simplify error messages for dump descriptor
  i40e: fix up scanf decoders
  i40e: more print_hex_dump use

Stephen Hemminger (1):
  i40e: make functions static and remove dead code

 drivers/net/ethernet/intel/i40e/i40e_adminq.c     |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c     |  80 --------
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c    | 132 ++++---------
 drivers/net/ethernet/intel/i40e/i40e_main.c       |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h  |   8 -
 drivers/net/ethernet/intel/igb/igb.h              |   9 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c      |   6 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |  94 +++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c    |  84 ++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 228 +++++++++-------------
 12 files changed, 243 insertions(+), 419 deletions(-)

-- 
1.8.3.1
