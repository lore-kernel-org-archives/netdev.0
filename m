From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-02-17
Date: Thu, 18 Feb 2016 01:03:57 -0800
Message-ID: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39536 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425574AbcBRJEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e/i40evf once again.

Mitch updates the use of a define instead of a magic number.  Adds support
for packet split receive on VFs, which is disabled by default.  Expands on
a code comment which was not verbose or really helpful.  Fixes an issue
where if a reset fails to complete and was not properly setting the
adapter state, which would cause a panic on rmmod, so set the adpater
state to DOWN to avoid a panic.

Jesse cleans up a "dump" in debugfs that never panned out to be useful.

Anjali adds a workaround for cases where we might have interrupts that get
lost but wright-back (WB) happened.  Fixes an issue by falling back to
enabling unicast, multicast and broadcast promiscuous mode when the driver
must disable it's use of "default port" (defport mode) due to internal
incompatibility with Multiple Function per Port (MFP).  Fixes an issue
where queues should never be enabled/disabled in the interrupt handler.

Kiran cleans up th code which used hard coded base VEB SEID since it was
removed from the specification.

Shannon adds a few bits for better debug messages.  Fixes an obscure corner
case, where it was possible to clear the NVM update wait flag when no
update_done message was actually received.

The following are changes since commit 5270c4dade091681313141a75f8401c61b72e82c:
  Merge branch 'vxlan-cleanups'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Anjali Singhai Jain (4):
  i40e: Add a SW workaround for lost interrupts
  i40e: Fix PROMISC mode for Multi-function per port (MFP) devices
  i40e: Do not disable queues in the Legacy/MSI Interrupt handler
  i40e: When in promisc mode apply promisc mode to Tx Traffic as well

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e to 1.4.15 and i40evf to 1.4.11.

Jesse Brandeburg (2):
  i40e: drop unused debugfs file "dump"
  i40e: trivial: cleanup use of pf->hw

Kiran Patil (1):
  i40e: Removal of code which relies on BASE VEB SEID

Mitch Williams (5):
  i40e: get rid of magic number
  i40evf: support packet split receive
  i40e/i40evf: avoid atomics
  i40e: expand comment
  i40evf: set adapter state on reset failure

Shannon Nelson (2):
  i40e: better error reporting for nvmupdate
  i40e: clean event descriptor before use

 drivers/net/ethernet/intel/i40e/i40e.h             |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  20 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 266 +--------------------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  40 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  69 +++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  44 ++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   8 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   5 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  31 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   6 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  67 +++++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  67 +++---
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   4 +
 18 files changed, 253 insertions(+), 399 deletions(-)

-- 
2.5.0
