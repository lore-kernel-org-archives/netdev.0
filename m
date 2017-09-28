From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 0/4] ravb: Add PHY reset support
Date: Thu, 28 Sep 2017 17:53:30 +0200
Message-ID: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi all,

This patch series adds optional PHY reset support during EthernetAVB driver
probe and system resume on the Renesas Salvator-X/XS development boards.

The rationale behind this is twofold:
  1. On Salvator-XS, the enable pin of the regulator providing PHY power
     is connected to PRESETn, and PSCI powers down the SoC during system
     suspend.  Hence a PHY reset is needed to restore network functionality
     after resume.
  2. Linux should not rely on the boot loader having reset the PHY, but
     should reset the PHY during driver probe.

The first two patches are destined for David's net-next tree. They update
the EthernetAVB DT bindings, and add support for resetting the PHY during
system resume.

The last two patches are destined for Simon's renesas tree.  They add
properties to describe the EthernetAVB PHY reset topology to the common
Salvator-X/XS and ULCB DTS files.

Thanks!

Geert Uytterhoeven (4):
  dt-bindings: net: ravb: Document optional reset-gpios property
  ravb: Add optional PHY reset during system resume
  arm64: dts: renesas: salvator-common: Add EthernetAVB PHY reset
  arm64: dts: renesas: ulcb: Add EthernetAVB PHY reset

 Documentation/devicetree/bindings/net/renesas,ravb.txt | 2 ++
 arch/arm64/boot/dts/renesas/salvator-common.dtsi       | 1 +
 arch/arm64/boot/dts/renesas/ulcb.dtsi                  | 1 +
 drivers/net/ethernet/renesas/ravb_main.c               | 9 +++++++++
 4 files changed, 13 insertions(+)

-- 
2.7.4

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
