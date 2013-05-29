From: Richard Genoud <richard.genoud@gmail.com>
Subject: Re: [PATCHv3 RESEND 0/6] ARM: sunxi: Add support for A10 Ethernet controller
Date: Wed, 29 May 2013 20:15:49 +0200
Message-ID: <CACQ1gAgp6o8HqQcv=4cWoAZze3wtXHMX+g+7KvV-pnC2W5=iyg@mail.gmail.com>
References: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, Emilio Lopez <emilio@elopez.com.ar>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/5/24 Maxime Ripard <maxime.ripard@free-electrons.com>:
> Hi,
>
> The Allwinner A10 SoC has an ethernet controller that seem to be specific to
> Allwinner. This IP has no public documentation, so exact
> details are quite sparse, and this code come from refactored Allwinner
> code.
>
> The rework to use NAPI is taking more time than expected, I'm still working
> on it, but it could probably be sent as a follow-up patch.
>
> Thanks,
> Maxime
>
> Changes from v2:
>   - Split the MDIO controller to a separate driver and make use of standards
>     device tree bindings
>   - Fixed various minor things as suggested by Florian Fainelli
>   - Added clock support now that we have a clock driver
>
> Changes from v1:
>   - Use phylib for the phy-related functions
>   - Use an optional regulator to power up the phy
>   - Rename the driver from Davicom Wemac to Allwinner EMAC, since it's the name
>     mentionned in the datasheet, and we have no strong evidence of a
>     relationship with Davicom
>   - Fix various small things around the driver: add defines for undocumented
>     values, fix documentation name and compatible example, etc.
>
> Maxime Ripard (4):
>   net: Add MDIO bus driver for the Allwinner EMAC
>   ARM: sun4i: Add muxing options for the ethernet controller
>   ARM: sunxi: Add EMAC controller node to sun4i DTSI
>   ARM: sunxi: Add EMAC Controller to Hackberry dt
>
> Stefan Roese (2):
>   net: Add EMAC ethernet driver found on Allwinner A10 SoC's
>   ARM: cubieboard: Enable ethernet (EMAC) support in dts
>
>  .../bindings/net/allwinner,sun4i-emac.txt          |  22 +
>  .../bindings/net/allwinner,sun4i-mdio.txt          |  26 +
>  arch/arm/boot/dts/sun4i-a10-cubieboard.dts         |  15 +
>  arch/arm/boot/dts/sun4i-a10-hackberry.dts          |  41 +
>  arch/arm/boot/dts/sun4i-a10.dtsi                   |  27 +
>  drivers/net/ethernet/Kconfig                       |   1 +
>  drivers/net/ethernet/Makefile                      |   1 +
>  drivers/net/ethernet/allwinner/Kconfig             |  44 +
>  drivers/net/ethernet/allwinner/Makefile            |   6 +
>  drivers/net/ethernet/allwinner/sun4i-emac.c        | 960 +++++++++++++++++++++
>  drivers/net/ethernet/allwinner/sun4i-emac.h        | 108 +++
>  drivers/net/ethernet/allwinner/sun4i-mdio.c        | 191 ++++
>  12 files changed, 1442 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt
>  create mode 100644 drivers/net/ethernet/allwinner/Kconfig
>  create mode 100644 drivers/net/ethernet/allwinner/Makefile
>  create mode 100644 drivers/net/ethernet/allwinner/sun4i-emac.c
>  create mode 100644 drivers/net/ethernet/allwinner/sun4i-emac.h
>  create mode 100644 drivers/net/ethernet/allwinner/sun4i-mdio.c
>
> --

I tested it successfully on cubieboard 1GB, on top of kernel 3.10-rc3,
nfsroot (debian wheezy)
I also added in sun4i-a10-cubieboard.dts
phy0: ethernet-phy@0 {
 reg = <1>;
},
like Emilio suggested.

running an iperf, there's some good perfs !
iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 192.168.1.10 port 5001 connected with 192.168.1.232 port 38169
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec   112 MBytes  94.1 Mbits/sec

That's great ! with this patchset, we can now run a server with a
vanilla kernel ( who needs more that a serial port and ethernet,
really ? ;) )

Tested-by: Richard Genoud <richard.genoud@gmail.com>
