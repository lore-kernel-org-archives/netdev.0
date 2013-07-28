From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Sun, 28 Jul 2013 04:41:04 -0700
Message-ID: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43491 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412Ab3G1LlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 07:41:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e100 and e1000e.

The e100 patch from Andy simply updates the netif_printk() to use
%*ph to dump small buffers.

The changes to e1000e include a fix from Dean Nelson to resolve a
issue where a pci_clear_master() was accidentally dropped during a
conflict resolution. Wei Young provides 2 patches, one removes an
assignment of the default ring size because it was a duplicate. The
second changes the packet split receive structure to use
PS_PAGE_BUFFERS macro for the length so that problems won't occur
when the length is changed.

The remaining patches for e1000e are from Bruce Allan, where he
provides a number of fixes and updates for I218.  In addition, a
fix for 82583 which can disappear off the PCIe bus, to resolve this,
disable ASPM L1.  Bruce also provides a fix to a previous commit
(commit e60b22c5b7 e1000e: fix accessing to suspended device) so that
devices are only taken out of runtime power management for those
ethtool operations that must access device registers.

The following are changes since commit dcfe8048de66c3468060c8a2ec2c04ae3725d002:
  bonding: remove bond_resend_igmp_join_requests read_unlock leftover
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Andy Shevchenko (1):
  e100: dump small buffers via %*ph

Bruce Allan (8):
  e1000e: disable ASPM L1 on 82583
  e1000e: iAMT connections drop on driver unload when jumbo frames
    enabled
  e1000e: low throughput using 4K jumbos on I218
  e1000e: Tx hang on I218 when linked at 100Half and slow response at
    10Mbps
  e1000e: ethtool unnecessarily takes device out of RPM suspend
  e1000e: enable support for new device IDs
  e1000e: do not resume device from RPM suspend to read PHY status
    registers
  e1000e: fix I217/I218 PHY initialization flow

Dean Nelson (1):
  e1000e: restore call to pci_clear_master()

Wei Yang (2):
  e1000e: Remove duplicate assignment of default rx/tx ring size
  e1000e: Use marco instead of digit for defining
    e1000_rx_desc_packet_split

 drivers/net/ethernet/intel/e100.c           |  15 ++-
 drivers/net/ethernet/intel/e1000e/82571.c   |   1 +
 drivers/net/ethernet/intel/e1000e/e1000.h   |   3 -
 drivers/net/ethernet/intel/e1000e/ethtool.c | 105 +++++++++++++++------
 drivers/net/ethernet/intel/e1000e/hw.h      |  10 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 140 +++++++++++++++++++---------
 drivers/net/ethernet/intel/e1000e/ich8lan.h |   6 ++
 drivers/net/ethernet/intel/e1000e/netdev.c  |  38 ++++----
 8 files changed, 217 insertions(+), 101 deletions(-)

-- 
1.7.11.7
