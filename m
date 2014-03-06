From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Wed,  5 Mar 2014 20:21:31 -0800
Message-ID: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51291 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840AbaCFEVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:21:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Most notable are:
Joe Perches provides a change to convert ether_addr_equal() to
ether_addr_equal_64bits() which is a bit more efficient.

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

The following are changes since commit e50287be7c007a10e6e2e3332e52466faf4b6a04:
  be2net: dma_sync each RX frag before passing it to the stack
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

Joe Perches (1):
  i40e: use ether_addr_equal_64bits

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
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  88 ++++-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         | 117 +++---
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   7 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 310 ++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 366 ++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   7 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  33 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   7 +-
 14 files changed, 1443 insertions(+), 362 deletions(-)

-- 
1.8.3.1
