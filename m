From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/16][pull request] Intel Wired LAN Driver Updates
Date: Fri, 20 Dec 2013 08:45:49 -0800
Message-ID: <1387557965-13241-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com,
	or.gerlitz@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43156 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753342Ab3LTQr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 11:47:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

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

The following are changes since commit 852ad5e631967ae2203cb08c5b6b42c26011ed63:
  Merge branch 'bridge_cleanups'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (1):
  i40e: Suppress HMC error to Interrupt message level

Catherine Sullivan (1):
  i40e: Populate and check pci bus speed and width

Jesse Brandeburg (1):
  i40e: update led set args

Joseph Gasparakis (2):
  i40e: Implementation of vxlan ndo's
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

 drivers/net/ethernet/intel/Kconfig                 |   1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |   5 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 193 ++++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  48 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 191 +++++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  57 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  20 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  62 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 581 ++++++---------------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 +-
 11 files changed, 633 insertions(+), 536 deletions(-)

-- 
1.8.3.1
