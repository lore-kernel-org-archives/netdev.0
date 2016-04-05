From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/18][pull request] 40GbE Intel Wired LAN Driver Updates 2016-04-05
Date: Tue,  5 Apr 2016 13:17:17 -0700
Message-ID: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10824 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759270AbcDEURh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Stefan converts dev_close() to ndo_stop() for ethtool offline self test,
since dev_close() causes IFF_UP to be cleared which will remove the
interface routes and addresses.

Alex bumps up the size of the transmit data buffer to 12K rather than 8K,
which provides a gain in throughput and a reduction in overhead for
putting together the frame.  Fixed an issue in the polling routines where
we were using bitwise operators to avoid the side effects of the
logical operators.  Then added support for bulk transmit clean for skbs.

Jesse fixed a sparse issue in the type casting in the transmit code and
fixed i40e_aq_set_phy_debug() to use i40e_status as a return code.

Catherine cleans up duplicated code.

Shannon fixed the cleaning up of the interrupt handling to clean up the
IRQs only if we actually got them set up.  Also fixed up the error
scenarios where we were trying to remove a non-existent timer or
worktask, which causes the kernel heartburn.

Mitch changes the notification of resets to the reset interrupt handler,
instead of the actual reset initiation code.  This allows the VFs to get
properly notified for all resets, including resets initiated by different
PFs on the same physical device.  Also moved the clearing of VFLR bit
after reset processing, instead of before which could lead to double
resets on VF init.  Fixed code comment to match the actual function name.

The following are changes since commit 15f41e2ba13a6726632e44b1180e805a61e470ad:
  Merge branch 'tcp-udp-misc'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Cox (1):
  i40evf: remove dead code

Alexander Duyck (3):
  i40e/i40evf: Allow up to 12K bytes of data per Tx descriptor instead
    of 8K
  i40e/i40evf: Fix handling of boolean logic in polling routines
  i40e/i40evf: Add support for bulk free in Tx cleanup

Catherine Sullivan (2):
  i40e/i40evf: Remove I40E_MAX_USER_PRIORITY define
  i40e/i40evf: Bump patch from 1.4.25 to 1.5.1

Jesse Brandeburg (2):
  i40e/i40evf: Fix casting in transmit code
  i40e: Fix up return code

Kevin Scott (1):
  i40e: Save off VSI resource count when updating VSI

Mitch Williams (4):
  i40e: Notify VFs of all resets
  i40e: Added code to prevent double resets
  i40evf: Add additional check for reset
  i40e: Change comment to reflect correct function name

Shannon Nelson (4):
  i40e: Remove MSIx only if created
  i40e: Assure that adminq is alive in debug mode
  i40e: Remove timer and task only if created
  i40e: Change unknown event error msg to ignore message

Stefan Assmann (1):
  i40e: call ndo_stop() instead of dev_close() when running offline
    selftest

 drivers/net/ethernet/intel/i40e/i40e.h             |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 12 ++++--
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 35 +++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 49 +++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        | 35 ++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 13 +++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 49 +++++++++++++---------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      | 35 ++++++++++++++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 17 +++-----
 11 files changed, 166 insertions(+), 88 deletions(-)

-- 
2.5.5
