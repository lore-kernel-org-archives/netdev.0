From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] 1GbE Intel Wired LAN Driver Updates 2016-09-22
Date: Thu, 22 Sep 2016 23:38:56 -0700
Message-ID: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com, bhelgaas@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25937 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752652AbcIWGjD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 02:39:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, igbvf and PCI quirks.

Wei Yongjun makes a function static to shut up sparse.

Todd bumps the igb and igbvf version, which is long overdue.

Jake fixes an issue where the PPS SYS_WRAP interrupt was not re-enabled
after a reset, which resulted in disabling of the PPS signaling.

Sasha adds a quirk for 82579 devices, which was reported by Red Hat.
The issue is that 82579 has a problem reattaching itself after being
detached, so disable the FLR capability in PCIe configuration space.

The following are changes since commit cdd0766d7da19085e88df86d1e5e21d9fe3d374f:
  Merge branch 'ftgmac100-ast2500-support'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Jacob Keller (1):
  igb: restore PPS signal on igb_ptp_reset

Sasha Neftin (1):
  PCI: disable FLR for 82579 device

Todd Fujinaka (2):
  igbvf: bump version to igbvf-2.4.0
  igb: bump version to igb-5.4.0

Wei Yongjun (1):
  igb: fix non static symbol warning

 drivers/net/ethernet/intel/igb/igb.h         |  1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    |  2 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c     |  5 ++++-
 drivers/net/ethernet/intel/igbvf/netdev.c    |  2 +-
 drivers/pci/quirks.c                         | 21 +++++++++++++++++++++
 6 files changed, 30 insertions(+), 5 deletions(-)

-- 
2.7.4
