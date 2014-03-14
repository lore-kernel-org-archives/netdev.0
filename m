From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/14][pull request] Intel Wired LAN Driver Updates
Date: Fri, 14 Mar 2014 16:34:21 -0700
Message-ID: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29252 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754791AbaCNXfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:35:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, i40e and i40evf.

I provide a code comment fix which David Miller noticed in the last
series of patches I submitted.

Shannon provides a patch to cleanup the NAPI structs when deleting the
netdev.

Anjali provides several patches for i40e, first fixes a bug in the update
filter logic which was causing a kernel panic.  Then provides a fix to
rename an error bit to correctly indicate the error.  Adds a definition
for a new state variable to keep track of features automatically disabled
due to hardware resource limitations versus user enforced feature disabled.
Anjali provides a patch to add code to handle when there is a filter
programming error due to a full table, which also resolves a previous
compile warning about an unused "*pf" variable introduced in the last i40e
series patch submission.

Jesse provides three i40e patches to cleanup strings to make more
consistent and to align with other Intel drivers.

Akeem cleans up a misleading function header comment for i40e.

Mitch provides a fix for i40e/i40evf to use the correctly reported number
of MSI-X vectors in the PF an VF.  Then provides a patch to use
dma_set_mask_and_coherent() which was introduced in v3.13 and simplifies
the DMA mapping code a bit.

v2:
- dropped the 2 ixgbe patches from Emil based on feedback from David Miller,
  where the 2 fixes should be handled in the net core to fix all drivers

The following are changes since commit 177943260a6088bec51fc6c04643d84e43bef423:
  6lowpan: reassembly: un-export local functions
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (1):
  i40e: Fix function comments

Anjali Singhai Jain (6):
  i40e: Fix a bug in the update logic for FDIR SB filter.
  i40e/i40evf: Some flow director HW definition fixes
  i40e: Define a new state variable to keep track of feature auto
    disable
  i40e: Add code to handle FD table full condition
  i40e: Bug fix for FDIR replay logic
  i40e: Let MDD events be handled by MDD handler

Jeff Kirsher (1):
  igb: Fix code comment

Jesse Brandeburg (3):
  i40e: make string references to q be queue
  i40e: cleanup strings
  i40e: simplified init string

Mitch Williams (2):
  i40e/i40evf: Use correct number of VF vectors
  i40e/i40evf: Use dma_set_mask_and_coherent

Shannon Nelson (1):
  i40e: delete netdev after deleting napi and vectors

 drivers/net/ethernet/intel/i40e/i40e.h             |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  25 ++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  37 +++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 190 +++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  60 ++++++-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   9 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   6 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  19 +--
 drivers/net/ethernet/intel/igb/igb_main.c          |   2 +-
 10 files changed, 269 insertions(+), 95 deletions(-)

-- 
1.8.3.1
