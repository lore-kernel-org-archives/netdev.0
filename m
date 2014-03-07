From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/12][pull request] Intel Wired LAN Driver Updates
Date: Thu,  6 Mar 2014 18:59:12 -0800
Message-ID: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56815 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378AbaCGC70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 21:59:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Most notable are:
Joseph completes the implementation of the ethtool ntuple rule
management interface by adding the get, update and delete interface
reset.

Akeem provides a fix to prevent a possible overflow due to multiplication
of number and size by using kzalloc, so use kcalloc.

Jesse provides an implementation for skb_set_hash() and adds the L4 type
return when we know it is an L4 hash.  He also adds a counter to
statistics for Tx timeouts to help users.  Lastly he provides a change
to stay away from the cache line where the done bit may be getting
written back for the transmit ring since the hardware may be writing the
whole cache line for a partial update.

Shannon cleans up code comments.

Anjali removes a firmware workaround for newer firmware since the number
of MSIx vectors are being reported correctly.

v2:
 -  dropped patch 01 of the series based on feedback from the author
    Joe Perches and Shannon Nelson.

The following are changes since commit 28f084cca35a73698568d8c060bbb98193021db5:
  bonding: fix const in options processing
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (1):
  i40e: Prevent overflow due to kzalloc

Anjali Singhai Jain (2):
  i40e: Remove a FW workaround for Number of MSIX vectors
  i40e: Remove a redundant filter addition

Catherine Sullivan (1):
  i40e/i40evf: Bump pf&vf build versions

Greg Rose (1):
  i40evf: Enable the ndo_set_features netdev op

Jesse Brandeburg (4):
  i40e/i40evf: i40e implementation for skb_set_hash
  i40e: count timeout events
  i40e: fix nvm version and remove firmware report
  i40e/i40evf: carefully fill tx ring

Joseph Gasparakis (1):
  i40e: Flow Director sideband accounting

Neerav Parikh (1):
  i40e: Fix static checker warning

Shannon Nelson (1):
  i40e: clean up comment style

 drivers/net/ethernet/intel/i40e/i40e.h             |  37 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 366 ++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  27 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 429 +++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  70 +++-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         | 117 +++---
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   7 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 310 ++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 366 ++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   7 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  33 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   7 +-
 14 files changed, 1432 insertions(+), 355 deletions(-)

-- 
1.8.3.1
