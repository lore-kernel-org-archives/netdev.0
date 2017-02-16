From: Chris Packham <chris.packham-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>
Subject: [PATCH v2 0/6] Updates for Marvell Switch SoCs
Date: Thu, 16 Feb 2017 21:50:34 +1300
Message-ID: <20170216085041.28337-1-chris.packham@alliedtelesis.co.nz>
Cc: Chris Packham <chris.packham-6g8wRflRTwXFdCa3tKVlE6U/zSkkHjvu@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Michael Turquette <mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Shortly after I posted my last series I got access to a more recent
Marvell SDK which had some device tree support for the switch SoCs I'd
been wanting. It was still based on an older kernel but it was a huge
improvement over what came before.

Patch 1/6 is a typo I noticed after my initial series was applied.

Patch 2/6 is a bit of a cleanup. I did initially struggle with how to
access individual parts of the DFX block as well as retaining a handle on
the entire thing for the switch driver to use.

Patch 3/6 is a re-jig of the dtsi files which is needed by 5/6. This is
required because I need to use the coreclk label on a different node. It
also means I don't have to disable nodes for blocks that only exist on
the Armada-XP.

Patch 4/6, 5/6 are split from the previous versions.

Patch 6/6 is the device tree portion of a change already in clk-next.

Chris Packham (6):
  ARM: dts: Fix typo in armada-xp-98dx4251
    Changes in v2
    - new
    Changes in v3:
    - none
  ARM: dts: armada-xp-98dx3236: combine dfx server nodes
    Changes in v2:
    - none
    Changes in v3:
    - none
  ARM: dts: Use armada-370-xp as a base for armada-xp-98dx3236
    Changes in v2:
    - Update root compatible strings in armada-xp-98dx3336.dtsi,
      armada-xp-98dx4251.dtsi, armada-xp-db-dxbc2.dts and
      armada-xp-db-xc3-24g4xg.dts
    Changes in v3:
    - none
  ARM: dts: mvebu: Add binding for mv98dx3236-soc-id
    Changes in v3:
    - new, split from driver
  ARM: mvebu: Add driver for mv98dx3236-soc-id
    Changes in v2:
    - none
    Changes in v3:
    - split from dts changes
  ARM: dts: mvebu: Move mv98dx3236 clock bindings
    Changes in v2:
    - New. Split out from "clk: mvebu: Expand mv98dx3236-core-clock support"
    Changes in v3:
    - Clarify why the old location was wrong (but worked).


 .../bindings/arm/marvell/mv98dx3236-soc-id.txt     |  14 ++
 .../devicetree/bindings/clock/mvebu-core-clock.txt |   7 +
 .../bindings/clock/mvebu-gated-clock.txt           |  11 ++
 .../devicetree/bindings/net/marvell,prestera.txt   |  13 +-
 arch/arm/boot/dts/armada-xp-98dx3236.dtsi          | 213 ++++++++++++++++-----
 arch/arm/boot/dts/armada-xp-98dx3336.dtsi          |   2 +-
 arch/arm/boot/dts/armada-xp-98dx4251.dtsi          |   2 +-
 arch/arm/boot/dts/armada-xp-db-dxbc2.dts           |   2 +-
 arch/arm/boot/dts/armada-xp-db-xc3-24g4xg.dts      |   2 +-
 arch/arm/mach-mvebu/mvebu-soc-id.c                 |  43 ++++-
 10 files changed, 242 insertions(+), 67 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/arm/marvell/mv98dx3236-soc-id.txt

-- 
2.11.0.24.ge6920cf
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
