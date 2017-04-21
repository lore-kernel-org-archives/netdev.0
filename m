From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Subject: [PATCH 0/4] RTL8211E-specified hacks
Date: Sat, 22 Apr 2017 07:24:32 +0800
Message-ID: <20170421232436.10924-1-icenowy@aosc.io>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some Pine64 boards are reported to have broken RTL8211E PHYs, which will fail
to work at 1000BASE-T mode if not workarounded.

The workaround is retrieved from Pine64, and is said to be from Realtek
engineer. It's undocumented but effective. (Tested on my Pine64 with GbE
broken)

The first patch is a small tweak for Realtek PHY driver, which removed the
"F" in page select register name, as RTL8211E also uses the same register
as page select (although with some different difinition).

The second patch adds a binding for the PHY, specified for this hack.

The third patch is the real driver part of this hack, which contains
some magic numbers from Pine64/Realtek.

The fourth patch is for reference only and should not be merged -- to
use it you will need sun8i-emac or dwmac-sun8i patchset applied.

Icenowy Zheng (4):
  net: phy: realtek: change macro name for page select register
  dt-bindings: add binding for RTL8211E Ethernet PHY
  net: phy: realtek: add disable RX delay hack for RTL8211E
  [DO NOT MERGE] arm64: allwinner: a64: enable RTL8211E PHY workaround

 .../devicetree/bindings/net/realtek,rtl8211e.txt   | 22 ++++++++++
 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  |  4 ++
 drivers/net/phy/realtek.c                          | 48 +++++++++++++++++++---
 3 files changed, 69 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/realtek,rtl8211e.txt

-- 
2.12.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
