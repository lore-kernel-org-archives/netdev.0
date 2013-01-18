From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/12][pull request] Intel Wired LAN Driver Updates
Date: Fri, 18 Jan 2013 07:04:35 -0800
Message-ID: <1358521487-28610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35352 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411Ab3ARPEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 10:04:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e and igb.  Most notably is the
added timestamp support in e1000e and additional software timestamp
support in igb.  As well as, the added thermal data support and SR-IOV
configuration support in igb.

v2- dropped the following patches from the previous 14 patch series
because changes were requested from the community:
  e1000e: add support for IEEE-1588 PTP
  igb: Report L4 Rx hash via skb->l4_rxhash

The following are changes since commit 887c95cc1da53f66a5890fdeab13414613010097:
  ipv6: Complete neighbour entry removal from dst_entry.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Bjorn Helgaas (1):
  e1000e: Use standard #defines for PCIe Capability ASPM fields

Bruce Allan (2):
  e1000e: add ethtool .get_eee/.set_eee
  e1000e: add support for hardware timestamping on some devices

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
  igb: Free any held skb that should have been timestamped on remove
  igb: Use in-kernel PTP_EV_PORT #define

 drivers/net/ethernet/intel/Kconfig             |  13 +
 drivers/net/ethernet/intel/e1000e/82571.c      |   2 +
 drivers/net/ethernet/intel/e1000e/defines.h    |  44 ++
 drivers/net/ethernet/intel/e1000e/e1000.h      |  47 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c    | 159 ++++++-
 drivers/net/ethernet/intel/e1000e/hw.h         |  11 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c    |  26 +-
 drivers/net/ethernet/intel/e1000e/netdev.c     | 382 ++++++++++++++-
 drivers/net/ethernet/intel/igb/Makefile        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 140 ++++++
 drivers/net/ethernet/intel/igb/e1000_82575.h   |  17 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h |  13 +
 drivers/net/ethernet/intel/igb/e1000_hw.h      |  20 +
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  16 +
 drivers/net/ethernet/intel/igb/igb.h           |  46 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  11 +
 drivers/net/ethernet/intel/igb/igb_hwmon.c     | 242 ++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c      | 632 +++++++++++++++++++++----
 drivers/net/ethernet/intel/igb/igb_ptp.c       |  65 ++-
 19 files changed, 1747 insertions(+), 141 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_hwmon.c

-- 
1.7.11.7
