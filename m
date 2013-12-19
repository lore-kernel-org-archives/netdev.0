From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Wed, 18 Dec 2013 22:34:36 -0800
Message-ID: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47454 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655Ab3LSGey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:34:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Anjali provides a patch to prevent messages from stray HMC events, except
at interrupt message level, and refactors the HMC error handling.

Catherine adds routines in probe to populate/check PCI bus speed and width,
then verify we are in a 8GT/s x8 PCIe slot and warn when we are not.

Shannon adds Wake-on-LAN support for i40e, fixes curly brace use as well as
return type for i40e_vsi_clear_rings().  Lastly implements the set_settings
and set_pauseparam ethtool functionality.

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

The following are changes since commit 020e867c755610fa5a2a08a69707e636cf368b55:
  isdn: use strlcpy() instead strcpy()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (1):
  i40e: Suppress HMC error to Interrupt message level

Catherine Sullivan (1):
  i40e: Populate and check pci bus speed and width

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

Shannon Nelson (3):
  i40e: add wake-on-lan support
  i40e: fix curly brace use and return type
  i40e: add set settings and pauseparam

 drivers/net/ethernet/intel/i40e/i40e.h             |   3 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 136 ++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 145 +++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 105 ++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  56 ++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  20 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  61 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 559 ++++++---------------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 +-
 10 files changed, 572 insertions(+), 518 deletions(-)

-- 
1.8.3.1
