From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Thu, 20 Mar 2014 01:32:50 -0700
Message-ID: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, emil.s.tantilov@intel.com,
	asharma@fb.com, donald.c.skidmore@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8065 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456AbaCTIdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e100, igb, igbvf, ixgbe and ixgbevf.

Stefan adds a igb patch to enable the ability strip VLAN header information
for packets bound for a VM on i350 hardware.

Joe Perches provides patches for e100, igb, igbvf, ixgbe and ixgbevf to
convert the use of __constant_<foo> to just <foo> to align with the rest
of the kernel.

Don provides two fixes for ixgbe, first resolves a link issue with DA
cables where we were not always freeing the firmware/software semaphore
after grabbing it.  Second stops caching whether the management firmware
was enabled, however since this is not static, we really need to verify
with each check.

Jacob provides six fixes/cleanups for ixgbe, most notably, correct
the stop_mac_link_on d3() to check the Core Clock Disable bit before
stopping link and to fully check to see if manage firmware is running or
could be enabled before bringing down the link.  Fix flow control
auto-negation for KR/KX/K4 interfaces, since setting up MAC link, the
cached autoc value and current autoc value were being incorrectly used to
determine whether link reset is required.

Emil provides a fix for ixgbe where there was a chance for aggressive
start_ndo_zmit() callers to sneak packets between enabling the Tx queues
and the link coming up.  To resolve this, move the call to enable Tx
queues to after the link is established.

The following are changes since commit a9baf10aafe7001501189099df4b91f90739e182:
  qeth: Fix IP version detection for VLAN traffic
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Don Skidmore (2):
  ixgbe: fix errors related to protected AUTOC calls
  ixgbe: Stop cacheing if the MNG FW enabled

Emil Tantilov (1):
  ixgbe: enable tx queues after link up

Jacob Keller (6):
  ixgbe: check Core Clock Disable bit
  ixgbe: fix ixgbe_stop_mac_link_on_d3_82599 to check mng correctly
  ixgbe: fix ixgbe_setup_mac_link_82599 autoc variables
  ixgbe: remove unused media type
  ixgbe: use ixgbe_read_pci_cfg_word
  ixgbe: clean up ixgbe_atr_compute_perfect_hash_82599

Joe Perches (5):
  e100: Convert uses of __constant_<foo> to <foo>
  igb: Convert uses of __constant_<foo> to <foo>
  igbvf: Convert uses of __constant_<foo> to <foo>
  ixgbe: Convert uses of __constant_<foo> to <foo>
  ixgbevf: Convert uses of __constant_<foo> to <foo>

Stefan Assmann (1):
  igb: enable VLAN stripping for VMs with i350

 drivers/net/ethernet/intel/e100.c                 |   4 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h      |   4 +
 drivers/net/ethernet/intel/igb/e1000_regs.h       |   1 +
 drivers/net/ethernet/intel/igb/igb_main.c         |  19 ++-
 drivers/net/ethernet/intel/igbvf/netdev.c         |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    |   1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    | 170 +++++-----------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   |  24 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c     |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  68 +++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |   4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   1 -
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
 15 files changed, 113 insertions(+), 206 deletions(-)

-- 
1.8.3.1
