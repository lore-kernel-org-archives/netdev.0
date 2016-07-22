From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 0/3] drivers: net: cpsw: fix driver loading/unloading
Date: Fri, 22 Jul 2016 16:58:44 +0300
Message-ID: <20160722135847.20557-1-grygorii.strashko@ti.com>
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

Grygorii Strashko (3):
  net: ethernet: ti: cpdma: fix lockup in cpdma_ctlr_destroy()
  drivers: net: cpsw: fix wrong regs access in cpsw_remove
  drivers: net: cpsw: use of_platform_depopulate()

 drivers/net/ethernet/ti/cpsw.c          | 19 +++++++++----------
 drivers/net/ethernet/ti/davinci_cpdma.c |  2 --
 2 files changed, 9 insertions(+), 12 deletions(-)

-- 
2.9.2
