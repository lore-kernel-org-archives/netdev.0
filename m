From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: ethernet: Add support for gmii2rgmii
 converter
Date: Fri, 1 Jul 2016 08:04:19 -0700
Message-ID: <57768673.2090103@gmail.com>
References: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	appanad@xilinx.com, michal.simek@xilinx.com,
	nicolas.ferre@atmel.com, punnaia@xilinx.com, anirudh@xilinx.com,
	harinik@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 30/06/2016 23:20, Kedareswara rao Appana a =C3=A9crit :
> This patch series does the following
> ---> Add support for gmii2rgmii converter.
> ---> Add support for gmii2rgmii converter in the macb driver.
>=20
> Earlier sent one RFC patch https://patchwork.kernel.org/patch/9186615=
/=20
> which includes converter related stuff also in macb driver.
> This patch series fixes this issue.

This still seems very adhoc and not completely explained. Can you
clarify how the gmmi2rgmii converter gets used?

Is the expectation that a MACB Ethernet adapter will be connected to a
RGMII PHY like this:

MACB <=3D> GMII2RGMII <=3D> RGMII PHY
MACB MDIO <=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> RGMII_PHY

and still have the ability to control both the PHY device's MDIO
registers and the GMII2RGMII converter and we need to make sure both
have matching settings, or is it something like this:

MACB <=3D> GMII2RGMII <=3D> RGMII PHY
MACB MDIO unconnected

and we lose the ability to query the PHY via MDIO?

As Nicolas pointed out, providing a binding documentation update may
help reviewers understand what is being accomplished here.

Thanks!

>=20
> Kedareswara rao Appana (2):
>   net: ethernet: xilinx: Add gmii2rgmii converter support
>   net: macb: Add gmii2rgmii phy converter support
>=20
>  drivers/net/ethernet/cadence/macb.c             |   21 ++++++-
>  drivers/net/ethernet/cadence/macb.h             |    3 +
>  drivers/net/ethernet/xilinx/Kconfig             |    7 ++
>  drivers/net/ethernet/xilinx/Makefile            |    1 +
>  drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c |   76 +++++++++++++=
++++++++++
>  include/linux/xilinx_gmii2rgmii.h               |   24 +++++++
>  6 files changed, 131 insertions(+), 1 deletions(-)
>  create mode 100644 drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c
>  create mode 100644 include/linux/xilinx_gmii2rgmii.h
>=20


--=20
=46lorian
