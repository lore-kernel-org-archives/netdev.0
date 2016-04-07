From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] 1GbE Intel Wired LAN Driver Updates 2016-04-06
Date: Wed,  6 Apr 2016 21:37:25 -0700
Message-ID: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7189 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758AbcDGEhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 00:37:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, igb and Kconfig.

Alex fixes igb where we were casting the MAC address as __beXX and then
passing it into le32_to_cpu, when we could simply cast as __lexx to
maintain consistency since it is already little endian.  Then enabled
bulk free in transmit cleanup for igb.

John Holland enables igb to pickup the MAC address from a device tree
blob when CONFIG_OF has been enabled.

Doron Shikmoni fixes a bug in the output of "ethtool -m ethX" where
the data byte appeared duplicated.

Stefan fixes up e1000 and e1000e ethtool offline tests which were calling
dev_close() which causes IFF_UP to be cleared which removes teh interface
routes and some addresses, so use ndo_stop() instead.

Jiri Benc cleans up some old links in the Kconfig for Intel drivers where
we referred to a URL which is no longer valid.  I am so glad Jiri has the
time in his day to spend clicking on and testing all the URL links in the
the kernel.

Arika Chen reverts the addition of a 'rtnl_unlock()' which had a unmatched
'rtnl_lock()' call before it.

The following are changes since commit 58a01d4dc43e60208b70ce08604b5bcbb907f0d1:
  Merge branch 'mlxsw-dcb'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Alexander Duyck (2):
  igb: Fix sparse warning about passing __beXX into leXX_to_cpup
  igb: Add support for bulk Tx cleanup & cleanup boolean logic

Arika Chen (1):
  Revert "igb: Fix a deadlock in igb_sriov_reinit"

Doron Shikmoni (1):
  igb: Garbled output for "ethtool -m"

Jiri Benc (1):
  net: intel: remove dead links

John Holland (1):
  igb: allow setting MAC address on i211 using a device tree blob

Stefan Assmann (2):
  e1000e: call ndo_stop() instead of dev_close() when running offline
    selftest
  e1000: call ndo_stop() instead of dev_close() when running offline
    selftest

 drivers/net/ethernet/intel/Kconfig               | 80 +++++-------------------
 drivers/net/ethernet/intel/e1000/e1000.h         |  2 +
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |  4 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c    |  8 +--
 drivers/net/ethernet/intel/e1000e/e1000.h        |  2 +
 drivers/net/ethernet/intel/e1000e/ethtool.c      |  4 +-
 drivers/net/ethernet/intel/e1000e/netdev.c       | 12 ++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c     |  3 +-
 drivers/net/ethernet/intel/igb/igb_main.c        | 32 ++++++----
 9 files changed, 53 insertions(+), 94 deletions(-)

-- 
2.5.5
