From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v5 00/13] net: ethernet: ti: cpts: update and fixes
Date: Tue, 6 Dec 2016 18:00:32 -0600
Message-ID: <20161207000045.28333-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is preparation series intended to clean up and optimize TI CPTS driver to
facilitate further integration with other TI's SoCs like Keystone 2.

Changes in v5:
- fixed copy paste error in cpts_release
- reworked cc.mult/shift and cc_mult initialization 

Changes in v4:
- fixed build error in patch
  "net: ethernet: ti: cpts: clean up event list if event pool is empty"
- rebased on top of net-next
 
Changes in v3:
- patches reordered: fixes and small updates moved first
- added comments in code about cpts->cc_mult
- conversation range (maxsec) limited to 10sec

Changes in v2:
- patch "net: ethernet: ti: cpts: rework initialization/deinitialization"
  was split on 4 patches
- applied comments from Richard Cochran
- dropped patch
  "net: ethernet: ti: cpts: add return value to tx and rx timestamp funcitons"
- new patches added:
  "net: ethernet: ti: cpts: drop excessive writes to CTRL and INT_EN regs"
  and "clocksource: export the clocks_calc_mult_shift to use by timestamp code"

Links on prev versions:
v4: https://lkml.org/lkml/2016/12/6/496
v3: https://www.spinics.net/lists/devicetree/msg153474.html
v2: http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1282034.html
v1: http://www.spinics.net/lists/linux-omap/msg131925.html

Grygorii Strashko (11):
  net: ethernet: ti: cpts: switch to readl/writel_relaxed()
  net: ethernet: ti: allow cpts to be built separately
  net: ethernet: ti: cpsw: minimize direct access to struct cpts
  net: ethernet: ti: cpts: fix unbalanced clk api usage in cpts_register/unregister
  net: ethernet: ti: cpts: fix registration order
  net: ethernet: ti: cpts: disable cpts when unregistered
  net: ethernet: ti: cpts: drop excessive writes to CTRL and INT_EN regs
  net: ethernet: ti: cpts: rework initialization/deinitialization
  net: ethernet: ti: cpts: move dt props parsing to cpts driver
  net: ethernet: ti: cpts: calc mult and shift from refclk freq
  net: ethernet: ti: cpts: fix overflow check period

Murali Karicheri (1):
  clocksource: export the clocks_calc_mult_shift to use by timestamp code

WingMan Kwok (1):
  net: ethernet: ti: cpts: clean up event list if event pool is empty

 Documentation/devicetree/bindings/net/cpsw.txt |   8 +-
 drivers/net/ethernet/ti/Kconfig                |   2 +-
 drivers/net/ethernet/ti/Makefile               |   3 +-
 drivers/net/ethernet/ti/cpsw.c                 |  84 ++++-----
 drivers/net/ethernet/ti/cpsw.h                 |   2 -
 drivers/net/ethernet/ti/cpts.c                 | 233 ++++++++++++++++++-------
 drivers/net/ethernet/ti/cpts.h                 |  80 ++++++++-
 kernel/time/clocksource.c                      |   1 +
 8 files changed, 297 insertions(+), 116 deletions(-)

-- 
2.10.1
