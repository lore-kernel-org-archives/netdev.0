From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Thu,  9 Jan 2014 04:52:09 -0800
Message-ID: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55960 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754835AbaAIMw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Anjali provides a fix where interrupts were not being re-enabled on ICR0
even though they were auto masked by hardware.  Then provides a fix to
cleanup RSS initialization because it was doing some extra work, so
remove the extra work and any bugs it created when managing number of
queues.  Since hardware requires a full packet template to be pointed to
when adding hardware flow filters, add the template and use it for
programming filters.

Jesse provides a fix to replace the use of driver specific defines with
kernel ETH_ALEN defines.  Then disables packet split because with the
use of GRO, we do not need the extra bus overhead.  Fixes spelling
error in code comment.

Kamil provides a fix for the driver where the hardware expects the MAC
address in a very specific format and the driver was filing the data
incorrectly.

Mitch provides a fix to resolve a panic on reset by adding checks to
VSI->rx_rings.  Then shortens alloc_rx_buff_failed and
alloc_rx_page_failed variables since both part of an RX specific
structure so just remove the _rx part of the name.  Then fixes
badly formatted lines, long lines and mis-formatted lines.

Shannon provides a fix to call AQ to release any reservation held by this
PF on the NVM resource lock on startup, in order to clear anything that
might have been left over from a previous run.  Then removes interrupt on
AQ error since nearly everything we do is synchronous, using the
interrupt-on-error bit is unnecessary and causing unneeded interrupts.
Adds code to handle the ability to send messages among the physical
function interfaces by the admin queue.

Catherine sets the MFP flag earlier in software init and uses that flag
to decide if other hardware work-arounds are required which turns
off flow director in MFP mode.

The following are changes since commit 54b553e2c16001d13e0186cad2531764065f9a1b:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (2):
  i40e: Re-enable interrupt on ICR0
  i40e: Cleanup reconfig rss path

Catherine Sullivan (1):
  i40e: Turn flow director off in MFP mode

Greg Rose (2):
  i40e: Fix GPL header
  i40e: add a comment on barrier and fix panic on reset

Jesse Brandeburg (4):
  i40e: use kernel specific defines
  i40e: disable packet split
  i40e: fix spelling errors
  i40e: Add a dummy packet template

Kamil Krawczyk (1):
  i40e: Fix MAC format in Write MAC address AQ cmd

Mitch Williams (2):
  i40e: shorten wordy fields
  i40e: trivial: formatting and checkpatch fixes

Shannon Nelson (3):
  i40e: release NVM resource reservation on startup
  i40e: remove interrupt on AQ error
  i40e: accept pf to pf adminq messages

 drivers/net/ethernet/intel/i40e/Makefile           |  7 +--
 drivers/net/ethernet/intel/i40e/i40e.h             |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      | 12 ++--
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_alloc.h       |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 14 +++--
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 13 ++---
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_diag.h        |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 33 ++++++++---
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h     |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 68 +++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_osdep.h       |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_register.h    |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_status.h      |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 44 +++++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        | 11 ++--
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 15 ++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    | 11 ++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 10 ++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  7 +--
 27 files changed, 176 insertions(+), 174 deletions(-)

-- 
1.8.3.1
