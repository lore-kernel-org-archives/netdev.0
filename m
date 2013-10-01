From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  0/9][pull request] Intel Wired LAN Driver Updates
Date: Tue,  1 Oct 2013 04:33:47 -0700
Message-ID: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:49978 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095Ab3JALd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:33:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbevf, ixgbe and igb.

Don provides 3 patches for ixgbevf where he cleans up a redundant
read mailbox failure check, adds a new function to wait for receive
queues to be disabled before disabling NAPI, and move the API
negotiation so that it occurs in the reset path.  This will allow
the PF to be informed of the API version earlier.

Jacob provides a ixgbevf and ixgbe patch.  His ixgbevf patch removes
the use of hw_dbg when the ixgbe_get_regs function is called in ethtool.
The ixgbe patch renames the LL_EXTENDED_STATS and some of the functions
required to implement busy polling in order to remove the marketing
"low latency" blurb which hides what the code actually does.

Leonardo provides a ixgbe patch to add support for DCB registers dump
using ethtool for 82599 and x540 ethernet controllers.

I (Jeff) provide a ixgbe patch to cleanup whitespace issues seen in a
code review.

Todd provides for igb to add support for i354 in the ethtool offline
tests.

Laura provides an igb patch to add the ethtool callbacks necessary to
configure the number of RSS queues.

The following are changes since commit b32418705107265dfca5edfe2b547643e53a732e:
  bonding: RCUify bond_set_rx_mode()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Don Skidmore (3):
  ixgbevf: cleanup redundant mailbox read failure check
  ixgbevf: add wait for Rx queue disable
  ixgbevf: move API neg to reset path

Fujinaka, Todd (1):
  igb: Add ethtool offline tests for i354

Jacob Keller (2):
  ixgbevf: do not print registers to dmesg in ixgbevf_get_regs
  ixgbe: remove marketing names from busy poll code

Jeff Kirsher (1):
  ixgbe: Cleanup the use of tabs and spaces

Laura Mihaela Vasilescu (1):
  igb: Add ethtool support to configure number of channels

Leonardo Potenza (1):
  ixgbe: ethtool DCB registers dump for 82599 and x540

 drivers/net/ethernet/intel/igb/igb.h              |   1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c      |  90 +++++++++++++++++-
 drivers/net/ethernet/intel/igb/igb_main.c         |  22 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  14 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  | 103 ++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |  40 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |   5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |  12 +--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  55 +----------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 111 +++++++++++-----------
 11 files changed, 283 insertions(+), 174 deletions(-)

-- 
1.8.3.1
