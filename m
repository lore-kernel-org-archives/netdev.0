From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v5 00/17][pull request] Intel Wired LAN Driver Updates
Date: Fri,  3 Jan 2014 21:56:28 -0800
Message-ID: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31987 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680AbaADF4u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 00:56:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and pci_regs.h.

Anjali provides a patch to prevent messages from stray HMC events, except
at interrupt message level, and refactors the HMC error handling.
  
Catherine adds routines in probe to populate/check PCI bus speed and width,
then verify we are in a 8GT/s x8 PCIe slot and warn when we are not.
  
Shannon adds Wake-on-LAN support for i40e, fixes curly brace use as well as
return type for i40e_vsi_clear_rings().
  
Joseph implements receive offload for VXLAN for i40e, where the hardware
supports checksum offload/verification of the inner/outer header.

Mitch provides the bulk of the changes, where he refactors the VF reset
code so that it works on real hardware.  Then does code cleanup by
calling existing functions to enable and disable queues for VFs and
remove unused functions.  Removes a unnecessary log messages that are
seen at every VF reset, for example complaining about disabling queues
that are already disabled.  Fixes an error return when the VF asks to
add an invalid MAC address and if the VF sends a bad message, make it
more informative about what is actually going on.

Jesse refactors the LED function to flash LED lights correctly.

v2:
 - removed patch 5 "i40e: add set settings and pauseparam" based on
   feedback from Ben Hutchings, will re-work that patch for later
   submission
 - Added patch "i40e: Implementation of vxlan ndo's" from Joseph to
   address Or Gerlitz's questions and concerns.  This patch adds the
   implementation for the VXLAN ndo's and allows the hardware to do
   receive checksum offload for inner packets on the UDP ports that
   VXLAN notifies us about.
 - Added patch "i40e: using for_each_set_bit to simplify the code"
   from Wei Yongjun.  This patch uses for_each_set_bit() to simply
   the code.

v3:
 - fixed indentation issue in patch 11 based on feedback from
   Sergei Shtylyov.

Sorry for the delayed release of v4, it was delayed to the holidays.

v4:
 - Addressed Or Gerlitz's concerns about trying to get a hold of a mutex
   while holding a spin lock in patch 6 by executing the AQ commands from
   a subtask.
 - Addressed David Miller's Kconfig concerns by creating a Kconfig VXLAN
   option for i40e and wrapped appropriate code with the config option in
   patch 6.
 - Updated patch 7 based on the changes made in patch 6 in the above two
   bullets.

v5:
 - Added the patch to pci_regs.h based on David Miller's feedback to add
   PCI defines for speed and width
 - Updated patch 3 description to better explain the changes based on
   feedback from David Miller
 - Updated patch 4 to use the newly added defines to pci_regs.h instead
   of local defines
 - Updated patch 7 to use <net/vxlan.h> in the #include based on feedback
   from David Miller

The following are changes since commit 128296fc3fa2f607050cc2c5d6dc90237f3cedb3:
  sh_eth: coding style fixes
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (1):
  i40e: Suppress HMC error to Interrupt message level

Catherine Sullivan (1):
  i40e: Populate and check pci bus speed and width

Jeff Kirsher (2):
  pci_regs.h: Add PCI bus link speed and width defines
  i40e: Implementation of VXLAN ndo's

Jesse Brandeburg (1):
  i40e: update led set args

Joseph Gasparakis (1):
  i40e: Rx checksum offload for VXLAN

Mitch Williams (8):
  i40e: move i40e_reset_vf
  i40e: refactor VF reset flow
  i40e: remove redundant code
  i40e: remove chatty log messages
  i40e: fix error return
  i40e: be more informative
  i40e: make a define from a large constant
  i40e: report VF MAC addresses correctly

Shannon Nelson (2):
  i40e: add wake-on-lan support
  i40e: fix curly brace use and return type

Wei Yongjun (1):
  i40e: using for_each_set_bit to simplify the code

 drivers/net/ethernet/intel/Kconfig                 |  13 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  13 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 193 ++++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  48 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 264 ++++++++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  57 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  20 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  53 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 581 ++++++---------------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 +-
 include/uapi/linux/pci_regs.h                      |   5 +
 13 files changed, 720 insertions(+), 539 deletions(-)

-- 
1.8.3.1
