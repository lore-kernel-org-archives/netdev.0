From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Fri,  8 Mar 2013 02:07:02 -0800
Message-ID: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12686 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177Ab3CHKHV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbevf and e1000e.

Alex's ixgbevf patch is meant to address several race issues that become
possible because next_to_watch could possibly be set to a value that shows
that the descriptor is done when it is not.  In order to correct that we
instead make next_to_watch a pointer that is set to NULL during cleanup,
and set to the eop_desc after the descriptor rings have been written.

Stephen's ixgbevf patch makes the PCI id table a const and reformats the
table to match what the ixgbe driver does.

The remaining 13 patches from Bruce are cleanup patches for e1000e to
resolve checkpatch.pl warnings/errors, removing blank lines where
necessary and fix code formatting.

The following are changes since commit 7f0e44ac9f7f12a2519bfed9ea4df3c1471bd8bb:
  ipv6 flowlabel: add __rcu annotations
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ixgbevf: Make next_to_watch a pointer and adjust memory barriers to
    avoid races

Bruce Allan (13):
  e1000e: cleanup CODE_INDENT checkpatch errors
  e1000e: cleanup SPACING checkpatch errors and warnings
  e1000e: cleanup LONG_LINE checkpatch warnings
  e1000e: cleanup LEADING_SPACE checkpatch warnings
  e1000e: cleanup PARENTHESIS_ALIGNMENT checkpatch checks
  e1000e: cleanup SPACING checkpatch checks
  e1000e: cleanup (add/remove) blank lines where appropriate
  e1000e: cleanup unusually placed comments
  e1000e: cleanup formatting of static structs
  e1000e: cleanup unnecessary line breaks
  e1000e: cleanup USLEEP_RANGE checkpatch checks
  e1000e: cleanup format of struct e1000_opt_list struct
  e1000e: cleanup - move defines to appropriate header file

Stephen Hemminger (1):
  ixgbevf: use PCI_DEVICE_TABLE macro

 drivers/net/ethernet/intel/e1000e/80003es2lan.c   | 131 ++++++-----
 drivers/net/ethernet/intel/e1000e/82571.c         |  38 ++-
 drivers/net/ethernet/intel/e1000e/82571.h         |   2 +
 drivers/net/ethernet/intel/e1000e/defines.h       |  25 +-
 drivers/net/ethernet/intel/e1000e/e1000.h         |  18 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c       | 177 +++++++-------
 drivers/net/ethernet/intel/e1000e/hw.h            |   4 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c       | 195 ++++++++--------
 drivers/net/ethernet/intel/e1000e/mac.c           |  10 +-
 drivers/net/ethernet/intel/e1000e/netdev.c        | 269 ++++++++++------------
 drivers/net/ethernet/intel/e1000e/nvm.c           |   2 +-
 drivers/net/ethernet/intel/e1000e/param.c         |  62 +++--
 drivers/net/ethernet/intel/e1000e/phy.c           | 130 +++++------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  80 ++++---
 15 files changed, 574 insertions(+), 571 deletions(-)

-- 
1.7.11.7
