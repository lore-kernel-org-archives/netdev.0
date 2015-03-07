From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-03-07
Date: Sat,  7 Mar 2015 07:03:08 -0800
Message-ID: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31672 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698AbbCGPD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Most notably, Greg provides the patch to remove the dreaded configfs
changes in the driver.

Shannon cleans up a sparse warning by simply straighting out the code
so it is less convoluted.  Fixes an issue where the vector allocation
was trying too hard to save vectors for VMDq, to the point of not giving
the PF enough when in a tight situation, such as an NPAR partition.
Changed the driver to make sure that the PF will get all the queues and
vectors it wants to fill out its destiny.  Cleans up reporting to only
print the port and VEB stats if it is the first partition of a
multiplexed port.

Catherine cleans up some duplicated code by simply removing the duplicate
code.

Kamil cleans up the driver by removing an un-needed endian conversion
because it is already done by a register read function.

Jesse fixes a variable width of a datatype, where a u16 should have been
a u32.  Also cleans up debug_read_register() to resolve some sparse
warnings.  Updates the driver to use prefetch() to get the next Tx
descriptor, like in ixgbe, to improve performance.

Akeem moves around code to enable/disable loopback so that other non-SRIOV
supported driver functions can take advantage of the changes.

Anjali cleans up the logging for adding/deleting FD-SB filters, since
ethtool shows all the filters on an interface.  Updates the driver to
use l4_tunnel type generically to keep code flow simple.  Simplifies
the RSS code since the driver initializes the rss_size_max in sw_init.

The following are changes since commit 1b5ef07e3dd3972d9111650fb6e0f5a566c741d8:
  rocker: sparse: fix dynamic allocation on stack warning
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (1):
  i40e: Move code to enable/disable Loopback to the main file

Anjali Singhai Jain (4):
  i40e: Avoid logs while adding/deleting FD-SB filters
  i40e: FD filters flush policy changes
  i40e/i40evf: Simplify tunnel selection logic
  i40e: Simplify code for rss_size_max config

Catherine Sullivan (1):
  i40e: Remove duplicate code

Greg Rose (1):
  i40e: Strip configfs code

Jesse Brandeburg (3):
  i40e: store msg_enable in the right size
  i40e: clean up debug_read_register
  i40e/i40evf: enable prefetch of Tx descriptors during cleanup

Kamil Krawczyk (1):
  i40e: Remove unneeded conversion

Shannon Nelson (3):
  i40e/i40evf: Refactor i40e_debug_aq and make some functions static
  i40e: rework vector reservation
  i40e: print port stats only on partition 1

Sravanthi Tangeda (1):
  i40e/i40evf: Bump version

 drivers/net/ethernet/intel/Kconfig                 |   9 -
 drivers/net/ethernet/intel/i40e/Makefile           |   1 -
 drivers/net/ethernet/intel/i40e/i40e.h             |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  60 ++--
 drivers/net/ethernet/intel/i40e/i40e_configfs.c    | 354 ---------------------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 227 +++++++++----
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  42 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  68 ----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 -
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  44 +--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  16 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 14 files changed, 284 insertions(+), 570 deletions(-)
 delete mode 100644 drivers/net/ethernet/intel/i40e/i40e_configfs.c

-- 
1.9.3
