From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Thu,  4 Apr 2013 04:37:47 -0700
Message-ID: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25690 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758781Ab3DDLiW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and igb.

For ixgbe (and igb), Alex fixes an issue where we were incorrectly checking
the entire frag_off field when we only wanted the fragment offset.  Alex
also provides a patch to drop the check for PAGE_SIZE in transmit since the
default configuration is to allocate 32k for all buffers.

Emil provides the third ixgbe patch with is a simple change to make the
calculation of eerd consistent between the read and write functions
by using | instead of + for IXGBE_EEPROM_RW_REG_START.

The remaining patches in the series are against igb, the largest being
my patch to cleanup code comments and whitespace to align the igb
driver with the networking style of code comments.  While cleaning up the
code comments, fixed several other whitespace/checkpatch.pl code
formatting issues.

Other notable igb patches are the added support for 100base-fx SFP,
added support for reading & exporting SFP data over i2c, and on EEE
capable devices, query the PHY to determine what the link partner
is advertising.

The following are changes since commit d66248326410ed0d3e813ebe974b3e6638df0717:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (5):
  igb: Support for 100base-fx SFP
  igb: Support to read and export SFF-8472/8079 data
  igb: Implement support to power sfp cage and turn on I2C
  igb: random code and comments fix
  igb: Fix sparse warnings on function pointers

Alexander Duyck (5):
  ixgbe: Mask off check of frag_off as we only want fragment offset
  ixgbe: Drop check for PAGE_SIZE from ixgbe_xmit_frame_ring
  igb: Mask off check of frag_off as we only want fragment offset
  igb: Pull adapter out of main path in igb_xmit_frame_ring
  igb: Use rx/tx_itr_setting when setting up initial value of itr

Emil Tantilov (1):
  ixgbe: don't do arithmetic operations on bitmasks

Jeff Kirsher (1):
  igb: Fix code comments and whitespace

Matthew Vick (1):
  igb: Enable EEE LP advertisement

 drivers/net/ethernet/intel/igb/e1000_82575.c    |  130 +--
 drivers/net/ethernet/intel/igb/e1000_82575.h    |    1 +
 drivers/net/ethernet/intel/igb/e1000_defines.h  |   34 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h       |   53 +-
 drivers/net/ethernet/intel/igb/e1000_i210.c     |   93 +-
 drivers/net/ethernet/intel/igb/e1000_i210.h     |    4 +
 drivers/net/ethernet/intel/igb/e1000_mac.c      |  111 +--
 drivers/net/ethernet/intel/igb/e1000_mac.h      |   17 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c      |   11 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.h      |   52 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c      |   25 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c      |  258 ++---
 drivers/net/ethernet/intel/igb/e1000_regs.h     |   49 +-
 drivers/net/ethernet/intel/igb/igb.h            |  132 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c    |  299 ++++--
 drivers/net/ethernet/intel/igb/igb_hwmon.c      |   29 +-
 drivers/net/ethernet/intel/igb/igb_main.c       | 1187 ++++++++++++-----------
 drivers/net/ethernet/intel/igb/igb_ptp.c        |   57 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    9 +-
 20 files changed, 1323 insertions(+), 1230 deletions(-)

-- 
1.7.11.7
