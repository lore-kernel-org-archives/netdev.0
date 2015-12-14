From: Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>
Subject: [PATCH v6 0/4] stmmac: create of compatible mdio bus for stmacc driver
Date: Mon, 14 Dec 2015 11:31:58 +0800
Message-ID: <1450063922-19481-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	vbridger-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Provide ability to specify a fixed phy in the device tree and
retain the mdio bus if no phy is found. This is needed where 
a dsa is connected via a fixed phy and uses the mdio bus for config.
Fixed ptp ref clock calculatins for the stmmac when ptp ref clock
is running at <= 50Mhz. Also add device tree setting to config
ptp clk source on socfpga platforms.

Changes from V5:
- Restore behaviour of unregister mdio bus when no phys found
  if there is no device tree node create the bus.
- Modify condition to allocate mdio_base_data conditional
  on fixed phy presece as well. Maintains existing behaviour
  in conditions where a fixed phy is not present.

Changes from V4:
- Restore #ifdef CONFIG_OF around setting of reset_gpio.
  Member doesn't exist when this isn't defined.

Changes from V3:
- Use if (IS_ENABLED(CONFIG_OF)) instead of #if.
  Reorder some code to reduce if statements.
- of_mdiobus_register already falls back to mdiobus_register
- Tested on system with CONFIG_OF

Changes from V2:
- Formatting, spaces & lines > 80 chars. Using checkpatch
- Drop PTP register debugfs patch.

Changes from V1:
- Fixed mismatch doc / code for ptp_ref_clk dt node. 
- Remove unit address from doc example.

Phil Reid (4):
  stmmac: create of compatible mdio bus for stmmac driver
  stmmac: Correct documentation on stmmac clocks.
  stmmac: Fix calculations for ptp counters when clock input = 50Mhz.
  stmmac: socfpga: Provide dt node to config ptp clk source.

 .../devicetree/bindings/net/socfpga-dwmac.txt      |  2 ++
 Documentation/devicetree/bindings/net/stmmac.txt   | 25 +++++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/common.h       |  2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  9 ++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |  9 +++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 19 +++++++---------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 26 +++++++++++++++++++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  2 +-
 8 files changed, 66 insertions(+), 28 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
