From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates 2014-11-03
Date: Mon,  3 Nov 2014 06:56:28 -0800
Message-ID: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44876 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752519AbaKCO4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Akeem adds a check for i40e so that flow director flush and reinit are
not done when flow director is not enabled.

Mitch fixes the i40evf driver to properly handle multiple admin queue
messages, by reinit the msg_size field each time we go through the loop.
Without this, we may receive truncated messages due to the firmware
thinking we have insufficient buffer size.  Also fixes the link checking
logic to only check the carrier state if the interface is actually
open, which allows link changes to be reported correctly without spamming
the VFs.  Updates i40e to inset the VSI ID in the QTX_CTL register
when configuring queues for VMDq VSIs.

Paul adds support for 10G-base-T in i40evf.

Jesse fixes i40e where the call to irq_dynamic_disable() was turning off
the interrupt completely when trying to set ITR to 0 (for lowest
moderation).

Shannon removes debugfs dump stats function, since it was not being
kept up-to-date and was redundant with the ethtool output.  Also, scales
back the LAN MSIx usage to force queue/vector sharing and leave some
vectors for Flow Director, VMDq, etc. when there are more cores than
vectors available to the PF.  Cleans up the error reporting for
get_lump() resource tracking errors.  Also adds a check for the
debug module parameter earlier to be able to catch the early configuration
phase admin queue messages.

The following are changes since commit 55b42b5ca2dcf143465968697fe6c6503b05fca1:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (1):
  i40e: Add condition to enter fdir flush and reinit

Jesse Brandeburg (1):
  i40e: avoid disable of interrupt when changing ITR

Mitch Williams (4):
  i40evf: properly handle multiple AQ messages
  i40e: fix link checking logic
  i40e: configure VM ID in qtx_ctl
  i40e: properly parse MDET registers

Paul M Stillwell Jr (1):
  i40evf: Add support for 10G base T parts

Shannon Nelson (4):
  i40e: remove debugfs dump stats
  i40e: scale msix vector use when more cores than vectors
  i40e: better wording for resource tracking errors
  i40e: enable debug earlier

 drivers/net/ethernet/intel/i40e/i40e_debugfs.c  | 93 +------------------------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c  |  2 -
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 67 ++++++++++++------
 drivers/net/ethernet/intel/i40evf/i40e_common.c |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h   |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  4 +-
 6 files changed, 51 insertions(+), 117 deletions(-)

-- 
1.9.3
