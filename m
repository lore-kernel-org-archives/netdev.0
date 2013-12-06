From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH 00/10] net: stmmac: Add sun7i GMAC glue layer
Date: Sat,  7 Dec 2013 01:29:33 +0800
Message-ID: <1386350983-13281-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <linux-sunxi+bncBCMILY6JWQBBBUETRCKQKGQEF4CAV4Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

This patch series adds Allwinner sun7i support to stmmac.
The Allwinner sun7i SoC A20 integrates an early version of
dwmac IP from Synopsys. On top of that is a hardware glue
layer. This layer needs to be configured before the dwmac
can be used.

The glue layer is implemented with existing callbacks in
stmmac platform data. Hardware feature flags are also passed
to the driver through platform data. As suggested by Maxime,
the platform data is tied to our compatible string.
Minimal modifications to stmmac core are made.

This version of dwmac IP requires store and forward DMA mode.
The relevant device tree property was documented, but not
implemented. The second patch adds this to stmmac platform
driver.

During testing, with stmmac built as a module, loading the
driver fails during the hardware probe phase. The main clock
is not enabled, and the hardware returns bogus results.
The first patch addresses this.

Comments?

Thanks,

wens


Chen-Yu Tsai (10):
  net: stmmac: Enable stmmac main clock when probing hardware
  net: stmmac: Honor DT parameter to force DMA store and forward mode
  net: stmmac: Use platform data tied with compatible strings
  net: stmmac: sunxi platfrom extensions for GMAC in Allwinner A20 SoC's
  ARM: dts: sun7i: Add GMAC controller node to sun7i DTSI
  ARM: dts: sun7i: Add pin muxing options for the GMAC
  ARM: dts: sun7i: cubietruck: Enable the GMAC
  ARM: dts: sun7i: cubieboard2: Enable GMAC instead of EMAC
  ARM: dts: sun7i: olinuxino-micro: Enable GMAC instead of EMAC
  ARM: dts: sun7i: Add ethernet alias for GMAC

 .../bindings/net/allwinner,sun7i-gmac.txt          | 22 +++++++
 arch/arm/boot/dts/sun7i-a20-cubieboard2.dts        | 23 +++----
 arch/arm/boot/dts/sun7i-a20-cubietruck.dts         |  8 +++
 arch/arm/boot/dts/sun7i-a20-olinuxino-micro.dts    | 23 +++----
 arch/arm/boot/dts/sun7i-a20.dtsi                   | 40 ++++++++++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        | 12 ++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 76 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  3 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 24 ++++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 33 +++++++---
 11 files changed, 215 insertions(+), 50 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun7i-gmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c

-- 
1.8.5.1
