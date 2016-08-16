From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/6][pull request] Intel Wired LAN Driver Updates 2016-08-16
Date: Tue, 16 Aug 2016 13:40:08 -0700
Message-ID: <1471380014-134435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27840 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753767AbcHPUkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 16:40:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to e1000e, igb, ixgbe and i40e.

Kshitiz Gupta provides a fix for igb to resolve the PHY delay compensation
math in several functions.

Jarod Wilson provides a fix for e1000e which had to broken up into 2
patches, first is prepares the driver for expanding the list of NICs
that have occasional ~10 hour clock jumps when being used for PTP.
Second patch actually fixes i218 silicon which has been experiencing
the clock jumps while using PTP.

Alex provides 2 patches for ixgbe now that he is back at Intel.  First
fixes setting VLNCTRL.VFE bit, which was left unchanged in earlier patches
which resulted in disabling VLAN filtering for all the VFs.  Second
corrects the support for disabling the VLAN tag filtering via the
feature bit.

Lastly, David fixes i40e which was causing a kernel panic when
non-contiguous traffic classes or traffic classes not starting with TC0,
were configured on a link partner switch.  To fix this, changed the
logic when determining the total number of TCs enabled.

The following are changes since commit a1560dd7a47f983419760aa7f6a481e3b910b54b:
  Merge branch 'mediatek-fixes'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 1GbE

Alexander Duyck (2):
  ixgbe: Force VLNCTRL.VFE to be set in all VMDq paths
  ixgbe: Re-enable ability to toggle VLAN filtering

Dave Ertman (1):
  i40e: check for and deal with non-contiguous TCs

Jarod Wilson (2):
  e1000e: factor out systim sanitization
  e1000e: fix PTP on e1000_pch_lpt variants

Kshitiz Gupta (1):
  igb: fix adjusting PTP timestamps for Tx/Rx latency

 drivers/net/ethernet/intel/e1000e/82571.c     |  6 ++-
 drivers/net/ethernet/intel/e1000e/e1000.h     |  1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c   |  3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c    | 66 ++++++++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 35 ++++++++++----
 drivers/net/ethernet/intel/igb/igb_ptp.c      | 26 +++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 19 +++++---
 7 files changed, 107 insertions(+), 49 deletions(-)

-- 
2.7.4
