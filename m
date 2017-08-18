From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 0/4] net: stmmac: Detect PHY location with phy-is-integrated
Date: Fri, 18 Aug 2017 14:21:14 +0200
Message-ID: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com, linux@armlinux.org.uk,
        maxime.ripard@free-electrons.com, wens@csie.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

The current way to find if the PHY is internal is to compare DT phy-mode
and emac_variant/internal_phy.
But it will negate a possible future SoC where an external PHY use the
same phy mode than the integrated one.

This patchs series adds a new way to find if the PHY is integrated, via
the phy-is-integrated DT property.

Since it exists both integrated and external ethernet-phy@1, they are merged in
the final DTB and so share all properties.
For avoiding this, and better represent the reality, we use a MDIO mux.

Note that sun8i-v3s-emac have also an integrated PHY, but since it lacks
any external PHY support, it is not necessary to add MDIO mux to it.

The first patch should go via the sunxi tree.
Note that this serie will need backporting the patch
"Documentation: net: phy: Add phy-is-integrated binding" which is in net-next

Thanks
Regards

Changes since v2:
- Add a MDIO mux for creating distinction between integrated and external MDIO.
- phy-is-integrated is not set in dtsi.

Changes since v1:
- Dropped phy-is-integrated documentation patch since another same patch was already merged
- Moved phy-is-integrated from SoC dtsi to final board DT.

Corentin Labbe (4):
  ARM: dts: sunxi: h3/h5: represent the mdio switch used by
    sun8i-h3-emac
  net: stmmac: dwmac-sun8i: choose internal PHY via phy-is-integrated
  net: stmmac: register parent MDIO node for sun8i-h3-emac
  dt-bindings: net: dwmac-sun8i: update documentation about integrated
    PHY

 .../devicetree/bindings/net/dwmac-sun8i.txt        | 112 +++++++++++++++++++--
 arch/arm/boot/dts/sunxi-h3-h5.dtsi                 |  28 +++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  |  16 +--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  12 ++-
 4 files changed, 146 insertions(+), 22 deletions(-)

-- 
2.13.0
