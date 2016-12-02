From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v3 00/13] net: ethernet: ti: cpts: update and fixes
Date: Fri, 2 Dec 2016 14:30:10 -0600
Message-ID: <20161202203023.25526-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It is preparation series intended to clean up and optimize TI CPTS driver to
facilitate further integration with other TI's SoCs like Keystone 2.

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
v2: http://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg1282034.html
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
 drivers/net/ethernet/ti/cpts.c                 | 239 +++++++++++++++++++------
 drivers/net/ethernet/ti/cpts.h                 |  80 ++++++++-
 kernel/time/clocksource.c                      |   1 +
 8 files changed, 304 insertions(+), 115 deletions(-)

-- 
2.10.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
