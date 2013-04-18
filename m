From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Thu, 18 Apr 2013 16:30:07 -0700
Message-ID: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14087 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936608Ab3DRXar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:30:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and igb.

The ixgbe changes contains 2 patches from the community, one which is a
fix from akepner to fix a issue where netif_running() in shutdown was
not done under rtnl_lock.  The other community fix from Joe Perches
cleans up #ifdef CONFIG_DEBUG_FS which is no longer necessary.  The
last ixgbe patch, from Jacob Keller, adds support for WoL on 82559
SFP+ LOM.

The remaining patches are against igb, 10 of which were previously
submitted in a pull request where changes were requested.

The following igb patches:
 igb: Support for 100base-fx SFP
 igb: Support to read and export SFF-8472/8079 data
are v2 based on feedback from Dan Carpenter and Ben Hutchings in
the previous pull request.

The largest set of changes are in my patch to cleanup code comments
and whitespace to align the igb driver with the networking style of
code comments.  While cleaning up the code comments, fixed several
other whitespace/checkpatch.pl code formatting issues.

Other notable igb patches are EEE capable devices query the PHY to
determine what the link partner is advertising, added support for
i354 devices and added support for spoofchk config.

The following are changes since commit c1cb0d3b569b1d21ada8666efb42dfd437617a09:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (5):
  igb: Support for 100base-fx SFP
  igb: Support to read and export SFF-8472/8079 data
  igb: Implement support to power sfp cage and turn on I2C
  igb: random code and comments fix
  igb: Fix sparse warnings on function pointers

Alexander Duyck (3):
  igb: Mask off check of frag_off as we only want fragment offset
  igb: Pull adapter out of main path in igb_xmit_frame_ring
  igb: Use rx/tx_itr_setting when setting up initial value of itr

Carolyn Wyborny (1):
  igb: Add support for i354 devices

Jacob Keller (1):
  ixgbe: Add support for WoL on 82599 SFP+ LOM

Jeff Kirsher (1):
  igb: Fix code comments and whitespace

Joe Perches (1):
  ixgbe: Remove unnecessary #ifdef CONFIG_DEBUG_FS tests

Lior Levy (1):
  igb: add support for spoofchk config

Matthew Vick (1):
  igb: Enable EEE LP advertisement

akepner (1):
  ixgbe: in shutdown, do netif_running() under rtnl_lock

 drivers/net/ethernet/intel/igb/e1000_82575.c   |  252 +++--
 drivers/net/ethernet/intel/igb/e1000_82575.h   |    2 +
 drivers/net/ethernet/intel/igb/e1000_defines.h |   50 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h      |   57 +-
 drivers/net/ethernet/intel/igb/e1000_i210.c    |   93 +-
 drivers/net/ethernet/intel/igb/e1000_i210.h    |    4 +
 drivers/net/ethernet/intel/igb/e1000_mac.c     |  124 +--
 drivers/net/ethernet/intel/igb/e1000_mac.h     |   17 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c     |   11 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.h     |   52 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c     |   27 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c     |  259 ++---
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   53 +-
 drivers/net/ethernet/intel/igb/igb.h           |  133 +--
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  345 +++++--
 drivers/net/ethernet/intel/igb/igb_hwmon.c     |   29 +-
 drivers/net/ethernet/intel/igb/igb_main.c      | 1270 +++++++++++++-----------
 drivers/net/ethernet/intel/igb/igb_ptp.c       |   61 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   15 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |    1 +
 21 files changed, 1604 insertions(+), 1256 deletions(-)

-- 
1.7.11.7
