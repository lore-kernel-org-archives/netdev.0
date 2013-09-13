From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/6][pull request] Intel Wired LAN Driver Updates
Date: Fri, 13 Sep 2013 14:12:04 -0700
Message-ID: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38706 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708Ab3IMVMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 17:12:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and e1000e.

Jacob provides a ixgbe patch to fix the configure_rx patch to properly
disable RSC hardware logic when a user disables it.  Previously we only
disabled RSC in the queue settings, but this does not fully disable
hardware RSC logic which can lead to unexpected performance issues.

Emil provides three fixes for ixgbe.  First fixes the ethtool loopback
test when DCB is enabled, where the frames may be modified on Tx
(by adding VLAN tag) which will fail the check on receive.  Then a fix
for QSFP+ modules, limit the speed setting to advertise only one speed
at a time since the QSFP+ modules do not support auto negotiation.
Lastly, resolve an issue where the driver will display incorrect info
for QSFP+ modules that were inserted after the driver has been loaded.

David Ertman provides to fixes for e1000e, one removes a comparison to
the boolean value true where evaluating the lvalue will produce the
same result.  The other fixes an error in the calculation of the
rar_entry_count, which causes a write of unkown/undefined register
space in the MAC to unknown/undefined register space in the PHY.

The following are changes since commit 38463e2c290426262cd9a75fe66cbbe2925a68c2:
  net/mlx4_en: Check device state when setting coalescing
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

David Ertman (2):
  e1000e: cleanup boolean comparison to true
  e1000e: fix overrun of PHY RAR array

Emil Tantilov (3):
  ixgbe: fix ethtool loopback diagnostic with DCB enabled
  ixgbe: limit setting speed to only one at a time for QSFP modules
  ixgbe: fix ethtool reporting of supported links for SFP modules

Jacob Keller (1):
  ixgbe: fully disable hardware RSC logic when disabling RSC

 drivers/net/ethernet/intel/e1000e/ethtool.c      |  8 ++++++++
 drivers/net/ethernet/intel/e1000e/ich8lan.c      | 13 +++++++-----
 drivers/net/ethernet/intel/e1000e/ich8lan.h      |  2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c       |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 25 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 19 ++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  1 +
 7 files changed, 61 insertions(+), 9 deletions(-)

-- 
1.8.3.1
