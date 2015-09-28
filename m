From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Updates 2015-09-28
Date: Mon, 28 Sep 2015 12:33:15 -0700
Message-ID: <1443468800-37102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40771 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751262AbbI1Tda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 15:33:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf and igb to resolve issues
seen and reported by Red Hat.

Kiran moves i40e_get_head() in preparation for the refactor of the Tx
timeout logic, so that it can be used in other areas of the driver.
Refactored the driver timeout logic by issuing a writeback request via
a software interrupt to the hardware the first time the driver detects
a hang.  This was due to the driver being too aggressive in resetting a
hung queue.

Shannon adds the GRE protocol to the transmit checksum encoding.

Anjali fixes an issue of forcing writeback too often, which caused us to
not benefit from NAPI.  We now disable force writeback in the clean
routine for X710 and XL710 adapters.  The X722 adapters do not enable
interrupt to force a writeback and benefit from WB_ON_ITR and so force
WB is left enabled for those adapters.

Stefan Assmann provides a fix for igb where SR-IOV was not getting
enabled properly and we ran into a NULL pointer if the max_vfs module
parameter is specified.  This is prevented by setting the
IGB_FLAG_HAS_MSIX bit before calling igb_probe_vfs().

The following are changes since commit 34c2d9fb0498c066afbe610b15e18995fd8be792:
  bridge: Allow forward delay to be cfgd when STP enabled
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai (1):
  i40e: Fix RS bit update in Tx path and disable force WB workaround

Kiran Patil (2):
  i40e: Move i40e_get_head into header file
  i40e/i40evf: refactor tx timeout logic

Shannon Nelson (1):
  i40e: add GRE tunnel type to csum encoding

Stefan Assmann (1):
  igb: assume MSI-X interrupts during initialization

 drivers/net/ethernet/intel/i40e/i40e.h        |   1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 272 +++++++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 214 ++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  26 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |  94 +--------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |   8 -
 drivers/net/ethernet/intel/igb/igb_main.c     |   3 +
 7 files changed, 277 insertions(+), 341 deletions(-)

-- 
2.4.3
