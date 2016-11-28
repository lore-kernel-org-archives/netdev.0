From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 00/13] net: ethernet: ti: cpts: update and fixes
Date: Mon, 28 Nov 2016 17:03:24 -0600
Message-ID: <20161128230337.6731-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:42767 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755880AbcK1XDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 18:03:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is preparation series intended to clean up and optimize TI CPTS driver to
facilitate further integration with other TI's SoCs like Keystone 2.

Changes in v2:
- patch "net: ethernet: ti: cpts: rework initialization/deinitialization"
  was split on 4 patches
- applied comments from Richard Cochran
- dropped patch
  "net: ethernet: ti: cpts: add return value to tx and rx timestamp funcitons"
- new patches added:
  "net: ethernet: ti: cpts: drop excessive writes to CTRL and INT_EN regs"
  and "clocksource: export the clocks_calc_mult_shift to use by timestamp code"

Link on v1:
 http://www.spinics.net/lists/linux-omap/msg131925.html

Grygorii Strashko (11):
  net: ethernet: ti: cpts: switch to readl/writel_relaxed()
  net: ethernet: ti: allow cpts to be built separately
  net: ethernet: ti: cpsw: minimize direct access to struct cpts
  net: ethernet: ti: cpts: fix unbalanced clk api usage in cpts_register/unregister
  net: ethernet: ti: cpts: fix registration order
  net: ethernet: ti: cpts: disable cpts when unregistered
  net: ethernet: ti: cpts: rework initialization/deinitialization
  net: ethernet: ti: cpts: move dt props parsing to cpts driver
  net: ethernet: ti: cpts: drop excessive writes to CTRL and INT_EN regs
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
 drivers/net/ethernet/ti/cpts.c                 | 232 ++++++++++++++++++-------
 drivers/net/ethernet/ti/cpts.h                 |  80 ++++++++-
 kernel/time/clocksource.c                      |   1 +
 8 files changed, 297 insertions(+), 115 deletions(-)

-- 
2.10.1
