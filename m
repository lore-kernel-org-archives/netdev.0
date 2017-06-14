From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] 10GbE Intel Wired LAN Driver Updates 2017-06-13
Date: Tue, 13 Jun 2017 17:38:01 -0700
Message-ID: <20170614003810.33189-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19685 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752259AbdFNAiU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 20:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf only.

Jake completes his fix ups for our drivers with the ixgbe changes to
resolve a race condition in processing timestamp requests.  These fixes
are the same fixes Jake applied earlier to the other drivers, including
the added statistic to help administrators know when an application
timestamp request is ignored.

With all the recent ixgbe/ixgbevf changes and fixes, Tony bumps the
the driver versions.  Then Tony provides a fix to resolve a static
analysis warning by changing a variable to unsigned integer since the
value can never be negative. 

Emil fixes an issue for X550 devices where the qde parameter was being
ignored, so PFQDE.HIDE_VLAN was not being set.

Jeff Mahoney from SuSE fixes a possible kernel crash, where there was
a small window where tasks writing to the sriov_numvfs sysfs attribute
can sneak in after we call register_netdev().  So we need to call
pci_set_drvdata() before and not after register_netdev() to preserve the
intent of commit 0fb6a55cc31f ("ixgbe: fix crash on rmmod after probe
fail").

The following are changes since commit b217566a525ff24334d17635a865f44b68c2c583:
  Merge branch 'net-dsa-Multi-CPU-ground-work'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Emil Tantilov (1):
  ixgbe: fix writes to PFQDE

Jacob Keller (4):
  ixgbe: fix race condition with PTP_TX_IN_PROGRESS bits
  ixgbe: avoid permanent lock of *_PTP_TX_IN_PROGRESS
  ixgbe: add statistic indicating number of skipped Tx timestamps
  ixgbe: check for Tx timestamp timeouts during watchdog

Jeff Mahoney (1):
  ixgbe: pci_set_drvdata must be called before register_netdev

Tony Nguyen (3):
  ixgbe: Bump version number
  ixgbevf: Bump version number
  ixgbe: Resolve cppcheck format string warning

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  5 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 48 +++++++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c      | 42 ++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
 6 files changed, 78 insertions(+), 23 deletions(-)

-- 
2.12.2
