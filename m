From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Wed, 26 Mar 2014 11:03:18 -0700
Message-ID: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3602 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754234AbaCZSES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 14:04:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igb, i40e and i40evf

Anjali provides i40e fix to remove the ATR filter on RST as well as FIN
packets.  Cleans up add_del_fdir() because it was used and implemented
only for the add, so change the name and drop a parameter.  Adds the
ability to drop a flow if we wanted to and adds a flow director
message level to be used for flow director specific messages.  Provide
a fallback debug flow for i40e if the reset fails or the firmware is
unresponsive.

Mitch fixes an issue on i40evf where the Tx watchdog handler was causing
an oops when sending an admin queue message to request a reset because
the admin queue functions use spinlocks.

Greg provides a change to i40e to make the alloc and free queue vector
calls orthogonal.

Shannon fixes i40e to verify the eeprom checksum and firmware CRC status
bits, and shutdown the driver if they fail.  This change stops the
processing of traffic, but does not kill the PF netdev so that the
NVMUpdate process still has a chance at fixing the image.  Also provides
a fix to make sure the VSI has a netdev before trying to use it in
the debugfs netdev_ops commands.

Jakub Kicinski provides patches for e1000e and igb to fix a number issues
found in the PTP code.

The following are changes since commit e74dbb73271c5c3e822af3aa66c9a28bf7dbfbfd:
  Merge branch 'bnx2x-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (6):
  i40e: Delete ATR filter on RST
  i40e: Cleanup in FDIR SB ethtool code
  i40e: Add functionality for FD SB to drop packets
  i40e/i40evf: Add an FD message level
  i40e: Use DEBUG_FD message level for an FD message
  i40e: Add a fallback debug flow for the driver

Greg Rose (1):
  i40e: Make the alloc and free queue vector calls orthogonal

Jakub Kicinski (4):
  e1000e: add timeout for TX HW time stamping work
  e1000e: remove redundant if clause from PTP work
  igb: never generate both software and hardware timestamps
  igb: fix race conditions on queuing skb for HW time stamp

Jesse Brandeburg (1):
  i40evf: remove double space after return

Mitch Williams (1):
  i40evf: fix oops in watchdog handler

Shannon Nelson (2):
  i40e: eeprom integrity check on load and empr
  i40e: check for netdev before debugfs use

 drivers/net/ethernet/intel/e1000e/e1000.h          |   2 +
 drivers/net/ethernet/intel/e1000e/ethtool.c        |   1 +
 drivers/net/ethernet/intel/e1000e/netdev.c         |  10 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 120 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  39 ++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  72 ++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  14 ++-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  10 +-
 drivers/net/ethernet/intel/igb/igb.h               |   3 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   7 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c           |   3 +
 16 files changed, 186 insertions(+), 102 deletions(-)

-- 
1.8.3.1
