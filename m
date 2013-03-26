From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/6][pull request] Intel Wired LAN Driver Updates
Date: Tue, 26 Mar 2013 03:42:28 -0700
Message-ID: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30723 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759224Ab3CZKmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 06:42:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbevf and igb.

The ixgbevf calls to pci_disable_msix() and to free the msix_entries
memory should not occur if device open fails.  Instead they should be
called during device driver removal to balance with the call to
pci_enable_msix() and the call to allocate msix_entries memory
during the device probe and driver load.

The remaining 4 of 5 igb patches are simple 1-3 line patches to fix
several issues such as possible null pointer dereference, PHC stopping
on max frequency, make sensor info static and SR-IOV initialization
reordering.

The remaining igb patch to fix anti-spoofing config fixes a problem
in i350 where anti spoofing configuration was written into a wrong
register.

The following are changes since commit a79ca223e029aa4f09abb337accf1812c900a800:
  ipv6: fix bad free of addrconf_init_net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Alex Williamson (2):
  igb: Fix null pointer dereference
  igb: SR-IOV init reordering

Jiri Benc (1):
  igb: fix PHC stopping on max freq

Lior Levy (1):
  igb: fix i350 anti spoofing config

Stephen Hemminger (1):
  igb: make sensor info static

xunleer (1):
  ixgbevf: don't release the soft entries

 drivers/net/ethernet/intel/igb/e1000_82575.c      | 33 +++++++++++++----------
 drivers/net/ethernet/intel/igb/igb_hwmon.c        |  2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |  4 +--
 drivers/net/ethernet/intel/igb/igb_ptp.c          |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 24 ++++++++++++++---
 5 files changed, 43 insertions(+), 22 deletions(-)

-- 
1.7.11.7
