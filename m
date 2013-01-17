From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Thu, 17 Jan 2013 03:35:05 -0800
Message-ID: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39512 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756446Ab3AQLf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 06:35:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e and igb.  Most notably is the
added timestamp support in e1000e and additional software timestamp
support in igb.  As well as, the added thermal data support and SR-IOV
configuration support in igb.

The following are changes since commit d59577b6ffd313d0ab3be39cb1ab47e29bdc9182:
  sk-filter: Add ability to lock a socket filter program
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  igb: Report L4 Rx hash via skb->l4_rxhash

Bjorn Helgaas (1):
  e1000e: Use standard #defines for PCIe Capability ASPM fields

Bruce Allan (3):
  e1000e: add ethtool .get_eee/.set_eee
  e1000e: add support for hardware timestamping on some devices
  e1000e: add support for IEEE-1588 PTP

Carolyn Wyborny (3):
  igb: Add i2c interface to igb.
  igb: Add support functions to access thermal data.
  igb: Enable hwmon data output for thermal sensors via I2C.

Greg Rose (1):
  igb: Enable SR-IOV configuration via PCI sysfs interface

Matthew Vick (5):
  igb: Add support for SW timestamping
  igb: Add timeout for PTP Tx work item
  igb: Add mechanism for detecting latched hardware Rx timestamp
  igb: Use in-kernel PTP_EV_PORT #define
  igb: Free any held skb that should have been timestamped on remove

 drivers/net/ethernet/intel/Kconfig             |  14 +
 drivers/net/ethernet/intel/e1000e/82571.c      |   2 +
 drivers/net/ethernet/intel/e1000e/Makefile     |   2 +-
 drivers/net/ethernet/intel/e1000e/defines.h    |  55 +++
 drivers/net/ethernet/intel/e1000e/e1000.h      |  56 ++-
 drivers/net/ethernet/intel/e1000e/ethtool.c    | 171 ++++++-
 drivers/net/ethernet/intel/e1000e/hw.h         |  13 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c    |  26 +-
 drivers/net/ethernet/intel/e1000e/netdev.c     | 487 +++++++++++++++++-
 drivers/net/ethernet/intel/e1000e/ptp.c        | 276 +++++++++++
 drivers/net/ethernet/intel/igb/Makefile        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 140 ++++++
 drivers/net/ethernet/intel/igb/e1000_82575.h   |  26 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h |  13 +
 drivers/net/ethernet/intel/igb/e1000_hw.h      |  20 +
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  16 +
 drivers/net/ethernet/intel/igb/igb.h           |  46 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  11 +
 drivers/net/ethernet/intel/igb/igb_hwmon.c     | 242 +++++++++
 drivers/net/ethernet/intel/igb/igb_main.c      | 653 +++++++++++++++++++++----
 drivers/net/ethernet/intel/igb/igb_ptp.c       |  65 ++-
 21 files changed, 2191 insertions(+), 145 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/e1000e/ptp.c
 create mode 100644 drivers/net/ethernet/intel/igb/igb_hwmon.c

-- 
1.7.11.7
