From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Wed, 14 May 2014 01:54:12 -0700
Message-ID: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6717 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753309AbaENIyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:54:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, igbvf, ixgbe, i40e and i40evf.

Emil provides a ixgbe patch to fix the detection of SFP+ capable interfaces
by identifying 82599 based NICs with no PHY type set as SFP capable which
allows the driver to detect the SFP module when the interface is brought
up.

Jacob provides eight patches to cleanup the ixgbe driver to resolve various
checkpatch.pl warnings/errors as well as minor coding style issues.

Stephen Hemminger and I provide simple cleanups of void functions which
had useless return statements at the end of the function which are not
needed.

The following are changes since commit 86b5d251d5ac4dda51a022b34cb29b4ce65a8cd5:
  sh_eth: replace devm_kzalloc() with devm_kmalloc_array()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Emil Tantilov (1):
  ixgbe: fix detection of SFP+ capable interfaces

Jacob Keller (8):
  ixgbe: clean up checkpatch warnings about CODE_INDENT and
    LEADING_SPACE
  ixgbe: fix function-like macro, remove semicolon
  ixgbe: fix checkpatch style of blank line after declaration
  ixgbe: fix several concatenated strings to single line
  ixgbe: add braces around else block
  ixgbe: don't check NULL for debugfs_remove_recursive
  ixgbe: add space between operands to &
  ixgbe: add /* fallthrough */ comment to case statements

Jeff Kirsher (1):
  igb/ixgbe: remove return statements for void functions

Stephen Hemminger (1):
  i40e,igb,ixgbe: remove usless return statements

 drivers/net/ethernet/intel/i40e/i40e_main.c        |  4 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  4 -
 drivers/net/ethernet/intel/igb/e1000_nvm.c         |  1 -
 drivers/net/ethernet/intel/igb/igb_main.c          |  1 -
 drivers/net/ethernet/intel/igbvf/ethtool.c         |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     | 62 ++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     | 85 ++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    | 45 +++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    | 16 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h | 24 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    | 28 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c   |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   | 90 ++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       | 10 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       |  6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       | 68 ++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       | 32 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      | 60 +++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      | 15 ++--
 24 files changed, 275 insertions(+), 301 deletions(-)

-- 
1.9.0
