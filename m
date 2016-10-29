From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] 40GbE Intel Wired LAN Driver Updates 2016-10-28
Date: Sat, 29 Oct 2016 00:30:41 -0700
Message-ID: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50914 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751028AbcJ2HbH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Carolyn provides a couple of fixes, first resolving a problem in the
client interface that was causing random stack traces in the RDMA driver
which was due to a timing related NULL pointer dereference.  Fixed a
problem where it could take a very long time to print the link down
notification, by changing how often we update link info from firmware.

Alex provides a number of changes, first is a re-write of the bust wait
loop in the Flow Director transmit function to reduce code size.  Cleans
up unused code in favor of the same functionality which can be inlined.
Dropped the functionality for SCTP since we cannot currently support it.
Cleans up redundant code in the receive clean-up path.  Finally cleaned
up the convoluted configuration for how the driver handled the debug
flags contained in msg_level.

Filip fixes an incorrect bit mask which was being used for testing the
"get link status".  Cleaned up a workaround that is no longer needed
for production NICs and was causing frames to pass while disregarding
the VLAN tagging.

Mitch brings another fix for the client interface supporting the VF RDMA
driver to allow clients to recover from reset by re-opening existing
clients.

Alan fixes a bug in which a "perfect storm" can occur and cause interrupts
to fail to be correctly affinitized.

Lihong fixes a confusing dmesg reported when users were using ethtool -L
option.

The following are changes since commit b09edbd07f876c9f7046c4aae1831e58919cffea:
  net caif: insert missing spaces in pr_* messages and unbreak multi-line strings
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (1):
  i40e/i40evf: fix interrupt affinity bug

Alexander Duyck (5):
  i40e: Rewrite Flow Director busy wait loop
  i40e: Remove unused function i40e_vsi_lookup
  i40e: Drop code for unsupported flow types
  i40e: Drop redundant Rx descriptor processing code
  i40e: Clean up handling of msglevel flags and debug parameter

Bimmy Pujari (2):
  i40e/i40evf: Changed version from 1.6.16 to 1.6.19
  i40e/i40evf: Changed version from 1.6.19 to 1.6.21

Carolyn Wyborny (2):
  i40e: Fix client interaction
  i40e: Fix for long link down notification time

David Ertman (1):
  i40e: Fix bit logic error in failure case

Filip Sadowski (2):
  i40e: Bit test mask correction
  i40e: Removal of workaround for simple MAC address filter deletion

Joe Perches (1):
  i40e: Make struct i40e_stats const

Lihong Yang (1):
  i40e: fix confusing dmesg info for ethtool -L option

Mitch Williams (1):
  i40e: reopen client after reset

Preethi Banala (1):
  i40e: group base mode VF offload flags

 drivers/net/ethernet/intel/i40e/i40e.h            |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_client.c     |  85 +++-----------
 drivers/net/ethernet/intel/i40e/i40e_client.h     |   2 -
 drivers/net/ethernet/intel/i40e/i40e_common.c     |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c    |  19 ---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 136 ++++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  98 +++++++---------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   |   4 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  49 +++++---
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h |   4 +
 drivers/net/ethernet/intel/i40evf/i40evf.h        |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  73 ++++++++----
 13 files changed, 232 insertions(+), 261 deletions(-)

-- 
2.7.4
