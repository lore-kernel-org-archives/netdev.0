From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] 100GbE Intel Wired LAN Driver Updates 2016-04-05
Date: Tue,  5 Apr 2016 01:01:12 -0700
Message-ID: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:25315 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757549AbcDEICZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:02:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Bruce provides nearly half of the patches in the series, most of which do
general cleanup of the driver.  These include semantic cleanups,
checkpatch.pl fixes, update driver to use BIT() kernel macro, use
BUILD_BUG_ON() where appropriate and use ether_addr_copy() instead of
memcpy().

Jake provides the remaining patches in the series, starting with a fix
for a possible NULL pointer deference.  Next delays initialization of the
service timer and service task until late in probe().  If we do not wait,
failures in probe do not properly cleanup the service timer or service
task items which result in a kernel panic.  Added better reporting during
error conditions.  Fixed another possible kernel panic where we were
clearing the interrupt scheme before we freed the mailbox IRQ.  Added
helper functions for setting strings and data for ethtool stats.  Fixed
comment mis-spelled words.

The following are changes since commit 15f41e2ba13a6726632e44b1180e805a61e470ad:
  Merge branch 'tcp-udp-misc'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Bruce Allan (7):
  fm10k: Move constants to the right of binary operators
  fm10k: cleanup remaining right-bit-shifted 1
  fm10k: Avoid crashing the kernel
  fm10k: demote BUG_ON() to WARN_ON() where appropriate
  fm10k: cleanup SPACE_BEFORE_TAB checkpatch warning
  fm10k: use ether_addr_copy to copy MAC address
  fm10k: prevent possibly uninitialized variable

Jacob Keller (9):
  fm10k: prevent null pointer dereference of msix_entries table
  fm10k: don't initialize service task until later in probe
  fm10k: base queue scheme covered by RSS
  fm10k: print error message when stop_hw fails
  fm10k: free MBX IRQ before clearing interrupt scheme
  fm10k: add helper functions to set strings and data for ethtool stats
  fm10k: correctly clean up when init_queueing_scheme fails
  fm10k: fix a minor typo in some comments
  fm10k: use ethtool_rxfh_indir_default for default redirection table

 drivers/net/ethernet/intel/fm10k/fm10k.h         |  14 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 227 ++++++++++++-----------
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  85 +++++----
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |   6 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  72 ++++---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      |  20 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c     |  24 +--
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |   8 +-
 10 files changed, 247 insertions(+), 215 deletions(-)

-- 
2.5.5
