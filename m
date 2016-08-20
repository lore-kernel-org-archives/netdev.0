From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH v2 0/4] meson: Meson8b and GXBB DWMAC glue driver
Date: Sat, 20 Aug 2016 11:35:34 +0200
Message-ID: <20160820093538.9707-1-martin.blumenstingl@googlemail.com>
References: <20160815164100.27766-1-martin.blumenstingl@googlemail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        sboyd@codeaurora.org,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org, khilman@baylibre.com,
        carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35915 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbcHTJf4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 05:35:56 -0400
In-Reply-To: <20160815164100.27766-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a DWMAC glue driver for the PRG_ETHERNET registers found in
Meson8b and GXBB SoCs. Based on the "old" meson6b-dwmac glue driver
the register layout is completely different.
Thus I introduced a separate driver.

Changes since v1:
- make clkin1 mandatory because the internal mux expects two clocks
  (in other words: this makes the driver consistent with how the
  hardware actually works)
- expose the MPLL2 clock for use by DT so we can pass it to the ethmac
- added a .remove function to the glue driver which disables and
  unprepares the clocks on driver removal


Martin Blumenstingl (4):
  net: dt-bindings: Document the new Meson8b and GXBB DWMAC bindings
  clk: gxbb: expose MPLL2 clock for use by DT
  net: stmmac: add a glue driver for the Amlogic Meson 8b / GXBB DWMAC
  ARM64: dts: meson-gxbb: use the new GXBB DWMAC glue driver

 .../devicetree/bindings/net/meson-dwmac.txt        |  45 ++-
 arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi        |   8 +-
 drivers/clk/meson/gxbb.h                           |   2 +-
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    | 329 +++++++++++++++++++++
 include/dt-bindings/clock/gxbb-clkc.h              |   1 +
 6 files changed, 374 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c

-- 
2.9.3
