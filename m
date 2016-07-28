From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 0/4] drivers: net: cpsw: fix driver loading/unloading
Date: Thu, 28 Jul 2016 20:50:33 +0300
Message-ID: <20160728175037.22053-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes set of isssues observed when CPSW driver module is unloaded/loaded:
1) rmmod: deadlock in cpdma_ctlr_destroy
2) rmmod: L3 back-trace and crash if all net interfaces are down, because CPSW
can be powerred down by PM runtime in this case.
3) insmod: mdio device is not recreated on next insmod
 - need to use of_platform_depopulate() in cpsw_remove().
4) rmmod: system crash on omap_device removal

Tested on: am437x-idk, am57xx-beagle-x15

Changes in v2:
- build warning fixed
- added fix for correct omap_device removal

Link on v1:
 https://lkml.org/lkml/2016/7/22/240

Grygorii Strashko (4):
  net: ethernet: ti: cpdma: fix lockup in cpdma_ctlr_destroy()
  drivers: net: cpsw: fix wrong regs access in cpsw_remove
  drivers: net: cpsw: use of_platform_depopulate()
  ARM: OMAP2+: omap_device: fix crash on omap_device removal

 arch/arm/mach-omap2/omap_device.c       |  2 +-
 drivers/net/ethernet/ti/cpsw.c          | 19 +++++++++----------
 drivers/net/ethernet/ti/davinci_cpdma.c |  3 ---
 3 files changed, 10 insertions(+), 14 deletions(-)

-- 
2.9.2
