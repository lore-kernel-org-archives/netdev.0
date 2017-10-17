From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2017-10-17
Date: Tue, 17 Oct 2017 11:21:04 -0700
Message-ID: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39952 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934563AbdJQSVl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and ethtool.

Alan provides most of the changes in this series which are mainly fixes
and cleanups.  Renamed the ethtool "cmd" variable to "ks", since the new
ethtool API passes us ksettings structs instead of command structs.
Cleaned up an ifdef that was not accomplishing anything.  Added function
header comments to provide better documentation.  Fixed two issues in
i40e_get_link_ksettings(), by calling
ethtool_link_ksettings_zero_link_mode() to ensure the advertising and
link masks are cleared before we start setting bits.  Cleaned up and fixed
code comments which were incorrect.  Separated the setting of autoneg in
i40e_phy_types_to_ethtool() into its own conditional to clarify what PHYs
support and advertise autoneg, and makes it easier to add new PHY types in
the future.  Added ethtool functionality to intersect two link masks
together to find the common ground between them.  Overhauled i40e to
ensure that the new ethtool API macros are being used, instead of the
old ones.  Fixed the usage of unsigned 64-bit division which is not
supported on all architectures.

Sudheer adds support for 25G Active Optical Cables (AOC) and Active Copper
Cables (ACC) PHY types.

The following are changes since commit 8a5f2166a6288ee4b5a393f1ebc8cfb26b0510f0:
  net: export netdev_txq_to_tc to allow sch_mqprio to compile as module
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (14):
  i40e: rename 'cmd' variables in ethtool interface
  i40e: remove ifdef SPEED_25000
  i40e: add function header for i40e_get_rxfh
  i40e: fix clearing link masks in i40e_get_link_ksettings
  i40e: fix i40e_phy_type_to_ethtool function header
  i40e: fix comment typo
  i40e: fix whitespace issues in i40e_ethtool.c
  i40e: group autoneg PHY types together
  ethtool: add ethtool_intersect_link_masks
  i40e: convert i40e_phy_type_to_ethtool to new API
  i40e: convert i40e_get_settings_link_up to new API
  i40e: rename 'change' variable to 'autoneg_changed'
  i40e: convert i40e_set_link_ksettings to new API
  i40e: fix u64 division usage

Sudheer Mogilappagari (1):
  i40e: Add new PHY types for 25G AOC and ACC support

 drivers/net/ethernet/intel/i40e/i40e.h             |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   4 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 721 +++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  58 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   4 +
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   4 +
 include/linux/ethtool.h                            |  10 +
 net/core/ethtool.c                                 |  16 +
 9 files changed, 521 insertions(+), 301 deletions(-)

-- 
2.14.2
