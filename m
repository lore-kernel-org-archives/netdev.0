From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2015-12-03
Date: Thu,  3 Dec 2015 05:25:45 -0800
Message-ID: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19487 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792AbbLCN0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Mitch updates the i40evf driver by increasing the maximum number of queues,
since future devices will allow for more queue pairs.  Cleans up a
duplicate printing of the driver info string done in init, since it is
already done in probe.  Cleaned up the several allocations which did
not need to be at atomic level, where GFP_KERNEL would work just fine.
Then makes i40e_sync_vsi_filters() a more mature function, make having
a common exit point so it will properly release the busy lock on the VSI
and propagate errors to the callers.  Then does some whitespace
housekeeping in i40evf.

Kiran moves and updates the detection/recovery of transmit queue hang code
to service_task from tx_timeout function.  Also fixed memory leak when
users program flow-director filter using ethtool (sideband filter
programming), the cause being the check of 'tx_buffer->skb' was preventing
'raw_buf' from being freed as part of the cleanup.

Jesse enabled the ability to turn off/on packet split using ethtool priv
flags.  Then does some housekeeping for both the i40e and i40evf drivers
which includes: remove unused/useless code, correct whitespace, remove
duplicate #include, fix incorrect comment, etc...

Neerav cleans up functions to gather Flow Control Rx XOFF stats, since
the recent change in the driver logic for checking transmit hang has been
moved, so these functions do not do anything meaningful any longer.

The following are changes since commit 6f24e5d599896b5091af72e4b3edfce6307627f7:
  sfc: use ALIGN macro for aligning frame sizes
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Catherine Sullivan (1):
  i40e/i40evf: Bump version to 1.4.7 for i40e and 1.4.3 for i40evf

Jesse Brandeburg (3):
  i40e: use priv flags to control packet split
  i40e: remove CONFIG_I40E_VXLAN
  i40e: trivial fixes

Kiran Patil (2):
  i40e: Detection and recovery of TX queue hung logic moved to
    service_task from tx_timeout
  i40e: Fix memory leaks, sideband filter programming

Mitch Williams (8):
  i40evf: increase max number of queues
  i40evf: set real num queues
  i40evf: remove duplicate string
  i40evf: don't use atomic allocation
  i40e: propagate properly
  i40evf: use correct types
  i40e: fix whitespace
  i40e/i40evf: use logical operator

Neerav Parikh (1):
  i40e: Remove separate functions gathering XOFF Rx stats

 drivers/net/ethernet/intel/Kconfig                 |  11 -
 drivers/net/ethernet/intel/i40e/i40e.h             |  15 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  27 +++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 240 ++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  29 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  18 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  48 ++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  15 ++
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  11 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  12 +-
 11 files changed, 226 insertions(+), 203 deletions(-)

-- 
2.5.0
