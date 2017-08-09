From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v4 00/12] Add the internal phy support
Date: Wed,  9 Aug 2017 20:07:43 +0800
Message-ID: <1502280475-736-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucky1.263xmail.com ([211.157.147.130]:35034 "EHLO
        lucky1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752459AbdHIMDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:03:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rk3228 and rk3328 support internal phy inside, let's enable
it to work. And the internal phy need to do some special setting, so
register the rockchip internal phy driver.

David Wu (12):
  net: phy: Add rockchip phy driver support
  multi_v7_defconfig: Make rockchip phy built-in
  arm64: defconfig: Enable CONFIG_ROCKCHIP_PHY
  net: stmmac: dwmac-rk: Remove unwanted code for rk3328_set_to_rmii()
  Documentation: net: phy: Add phy-is-internal binding
  net: stmmac: dwmac-rk: Add internal phy support
  net: stmmac: dwmac-rk: Add internal phy support for rk3228
  net: stmmac: dwmac-rk: Add internal phy supprot for rk3328
  ARM: dts: rk322x: Add support internal phy for gmac
  ARM: dts: rk3228-evb: Enable the internal phy for gmac
  ARM64: dts: rockchip: Add gmac2phy node support for rk3328
  ARM64: dts: rockchip: Enable gmac2phy for rk3328-evb

 Documentation/devicetree/bindings/net/phy.txt      |   3 +
 .../devicetree/bindings/net/rockchip-dwmac.txt     |   4 +-
 arch/arm/boot/dts/rk3228-evb.dts                   |  32 +++
 arch/arm/boot/dts/rk322x.dtsi                      |   8 +-
 arch/arm/configs/multi_v7_defconfig                |   1 +
 arch/arm64/boot/dts/rockchip/rk3328-evb.dts        |  17 ++
 arch/arm64/boot/dts/rockchip/rk3328.dtsi           |  37 ++++
 arch/arm64/configs/defconfig                       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 129 +++++++++++-
 drivers/net/phy/Kconfig                            |   5 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/rockchip.c                         | 233 +++++++++++++++++++++
 12 files changed, 460 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/phy/rockchip.c

-- 
1.9.1
