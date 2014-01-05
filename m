From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Sun,  5 Jan 2014 02:46:52 -0800
Message-ID: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21383 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083AbaAEKrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Anjali provides two cleanups to remove unnecessary code and a fix
to resolve debugfs dumping only half the NVM.  Then provides a fix
to ethtool NVM reads where shadow RAM was used instead of actual
NVM reads.

Jesse provides a couple of fixes, one removes custom i40e functions
which duplicate existing kernel functionality.  Second fixes constant
cast issues by replacing __constant_htons with htons.

Mitch provides a couple of fixes for the VF interfaces in i40e.  First
provides a fix to guard against VF message races with can cause a panic.
Second fix reinitializes the buffer size each time we clean the ARQ,
because subsequent messages can be truncated. Lastly adds functionality
to enable/disable ICR 0 dynamically.

Vasu adds a simple guard against multiple includes of the i40e_txrx.h
file.

Shannon provides a couple of fixes, first fix swaps a couple of lines
around in the error handling if the allocation for the VSI array fails.
Second fixes an issue where we try to free the q_vector that has not
been setup which can panic the kernel.

David provides a patch to save off the point to memory and the length
of 2 structs used in the admin queue in order to store all info about
allocated kernel memory.

Neerav fixes ring allocation where allocation and clearing of rings
for a VSI should be using the alloc_queue_pairs and not num_queue_pairs.
Then removes the unused define for multi-queue enabled.

The following are changes since commit a1d4b03a076d95edc88d070f7627a73ab80abddc:
  Merge branch 'bgmac'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (4):
  i40e: Dump the whole NVM, not half
  i40e: Change the ethtool NVM read method to use AQ
  i40e: Remove unnecessary prototypes
  i40e: remove un-necessary io-write

David Cassard (1):
  i40e: keep allocated memory in structs

Jesse Brandeburg (2):
  i40e: fix mac address checking
  i40e: fix constant cast issues

Mitch Williams (3):
  i40e: guard against vf message races
  i40e: use functions to enable and disable icr 0
  i40e: reinit buffer size each time

Neerav Parikh (2):
  i40e: Fix ring allocation
  i40e: I40E_FLAG_MQ_ENABLED is not used

Shannon Nelson (2):
  i40e: fix error handling when alloc of vsi array fails
  i40e: catch unset q_vector

Vasu Dev (1):
  i40e: add header file flag _I40E_TXRX_H_

 drivers/net/ethernet/intel/i40e/i40e.h             |  40 +++-----
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      | 103 +++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |  13 +--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  27 ------
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  68 +++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  47 +++++-----
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   1 -
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   4 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  28 +++---
 11 files changed, 162 insertions(+), 185 deletions(-)

-- 
1.8.3.1
