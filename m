From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] 1GbE Intel Wired LAN Driver Updates 2015-12-14
Date: Mon, 14 Dec 2015 21:38:35 -0800
Message-ID: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59684 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbbLOFiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 00:38:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e and igb.

Alex Duyck changes e1000_up() to void since it always returned 0, also
by making it void, we can drop some code since we no longer have to worry
about non-zero return values.

Aaron Sierra removes GS40G specific defines and functions since the i210
internal PHY can be accessed with the access functions shared by 82580,
i350 and i354 devices.  Also removes the code to add the PHY address into
the PCDL register address, since there is no real reason to do so.

Joe updates the cable length function reports all four pairs true min, max
and average cable length for i210.  Also updated ethtool to use enum-based
labels instead of hard coded values.

Benjamin Poirier cleans up code that is never reachable since MSI-X
interrupts are not shared in e1000e.  Also removes the ICR read in the
other interrupt handler, since the information is not needed and IMS is
configured such that the only link status change can trigger the other
interrupt handler.  Fixed in MSI-X mode, there is no handler for the LSC
interrupt so there is no point in writing that to ICS now that we always
assume other interrupts are caused by LSC.

The following are changes since commit cb4396edd84ed73081635fb933d19c1410fafaf4:
  drivers/net: fix eisa_driver probe section mismatch
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Aaron Sierra (2):
  igb: Remove GS40G specific defines/functions
  igb: Don't add PHY address to PCDL address

Alexander Duyck (1):
  e1000e: Switch e1000e_up to void, drop code checking for error result

Benjamin Poirier (4):
  e1000e: Remove unreachable code
  e1000e: Do not read ICR in Other interrupt
  e1000e: Do not write lsc to ics in msi-x mode
  e1000e: Fix msi-x interrupt automask

Joe Schultz (2):
  igb: Improve cable length function for I210, etc.
  igb: Explicitly label self-test result indices

 drivers/net/ethernet/intel/e1000e/defines.h    |   3 +-
 drivers/net/ethernet/intel/e1000e/e1000.h      |   2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c     |  80 ++++++---------
 drivers/net/ethernet/intel/igb/e1000_82575.c   |  13 +--
 drivers/net/ethernet/intel/igb/e1000_defines.h |   5 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h      |   1 +
 drivers/net/ethernet/intel/igb/e1000_i210.c    |   5 +-
 drivers/net/ethernet/intel/igb/e1000_i210.h    |   2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 135 +++++++++----------------
 drivers/net/ethernet/intel/igb/e1000_phy.h     |  15 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  38 ++++---
 11 files changed, 120 insertions(+), 179 deletions(-)

-- 
2.5.0
