From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] Intel Wired LAN Driver Updates 2015-09-22
Date: Tue, 22 Sep 2015 16:54:19 -0700
Message-ID: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8434 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934114AbbIVXyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, igbvf, ixgbe, ixgbevf and
fm10k.

Jacob provides several updates for fm10k, which cleans up comments and
most notably a fix for a corner case issue with the PF/VF mailbox code.
The issue being fm10k_mbx_reset_work clears various states about the
mailbox, but does not clear the Tx FIFO head/tail pointers.  We also
are not able to simply clear these pointers, as we would drop
untransmitted messages without error.  Also adds support for extra debug
statistics, which provides the ability to see what the PF thinks the
VF mailboxes look like.

Don adds support for SFP+ in X550 and support for SCTP flow director
filters SCTP mask.

Francois Romieu dusts off the e1000 driver and removes some dead calls
to e1000_init_eeprom_params().

Toshiaki Makita provides three patches to enable TSO for stacked VLAN's
on e1000e, igbvf and ixgbevf.

Mark provides the first of several ixgbe updates.  First updates the
driver to accept SFP not present error for all devices, since an SFP
can still be inserted.  Adds support for SFP insertion interrupt on
X550EM devices with SPFs.  Adds I2C combined operations on X550EM
(not X550) devices.  Moved the setting of lan_id to before any I2C
eeprom access.  Lastly, set the bit bang mode in the hardware when
performing bit banding I2C operations on X550.

The following are changes since commit 99cb99aa055a72d3880d8a95a71034c4d64bcf9a:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Don Skidmore (2):
  ixgbe: Add SFP+ detection for X550 hardware
  ixgbe: Add fdir support for SCTP on X550

Francois Romieu (1):
  e1000: remove dead e1000_init_eeprom_params calls

Jacob Keller (5):
  fm10k: remove comment about rtnl_lock around mbx operations
  fm10k: drop transmitted messages in Tx FIFO as part of reset_work
  fm10k: create "correct" header for the remote end on connect
  fm10k: TRIVIAL remove unnecessary comma
  fm10k: add support for extra debug statistics

Mark Rustad (6):
  ixgbe: Accept SFP not present errors on all devices
  ixgbe: Add X550EM support for SFP insertion interrupt
  ixgbe: Provide I2C combined on X550EM
  ixgbe: Provide unlocked I2C methods
  ixgbe: Set lan_id before first I2C eeprom access
  ixgbe: Enable bit-banging mode on X550

Toshiaki Makita (3):
  igbvf: Enable TSO for stacked VLAN
  e1000e: Enable TSO for stacked VLAN
  ixgbevf: Enables TSO for stacked VLAN

 drivers/net/ethernet/intel/e1000/e1000_hw.c       |   8 -
 drivers/net/ethernet/intel/e1000e/netdev.c        |   1 +
 drivers/net/ethernet/intel/fm10k/fm10k.h          |  19 ++
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c  | 216 ++++++++++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c      |   5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |  15 ++
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c      |  48 +++-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c      |  22 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h     |   6 +
 drivers/net/ethernet/intel/igbvf/netdev.c         |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |  10 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  17 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c      | 270 +++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |   8 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |   5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |   7 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   1 +
 17 files changed, 568 insertions(+), 91 deletions(-)

-- 
2.4.3
