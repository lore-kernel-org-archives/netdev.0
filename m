From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 0/4] phylib: add context argument to adjust link callbacks
Date: Fri, 6 Jul 2012 23:41:33 +0200
Message-ID: <201207062341.33700.florian@openwrt.org>
References: <1341604653-19944-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, cyril@ti.com,
	grant.likely@secretlab.ca, linux-keystone@list.ti.com
To: s-paulraj@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57654 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486Ab2GFVlb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 17:41:31 -0400
Received: by eeit10 with SMTP id t10so3782332eei.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 14:41:30 -0700 (PDT)
In-Reply-To: <1341604653-19944-1-git-send-email-s-paulraj@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sandeep,

Le vendredi 06 juillet 2012 21:57:33, s-paulraj@ti.com a =E9crit :
> From: Sandeep Paulraj <s-paulraj@ti.com>
>=20
> This series of 4 patches adds a new context argument for the adjust l=
ink
> callbacks. The existing phy_connect() and its variants don't have a w=
ay to
> pass any private context information. This becomes necessary when, a =
SOC
> has an on chip switch with multiple ports. We need port specific
> information to figure out which port a given callback belongs to.
> We can pass this context information in the phy_connect() and its
> variants. This in turn gets passed into the adjust link callbacks on =
link
> state change events.

Assuming that you want to use a phydev per one of your switch port, thi=
s would=20
mean that you register multiple phydevs within your ethernet driver. If=
 so,=20
each phydev is already unique, and most likely also has an unique MDIO =
bus=20
address, this makes me wonder what is the purpose of the private pointe=
r then?

>=20
> NOTE: At this point of time patch 4 in this series passes a "NULL" to
> the phy_connect() and its variants for all drivers that currently use
> phy_connect() and its variants. This patch has been tested on a
> Texas Instruments SOC, patches for which, as of now have not yet been
> upstreamed; as a result of which this patch series does not yet
> have an example of how this new feature is being actually used.

As David will probably tell you, introducing a new interface without an=
y user=20
does not increase the chance of geting your patches merged ;)

>=20
> Sandeep Paulraj (4):
>   phylib: factor out handler callouts into helper
>   phylib: add context argument to adjust link callback
>   of/mdio: add context argument to adjust link callback
>   net: add context callback parameter to phy connect
>=20
>  drivers/net/ethernet/8390/ax88796.c                |    4 ++--
>  drivers/net/ethernet/adi/bfin_mac.c                |    4 ++--
>  drivers/net/ethernet/aeroflex/greth.c              |    7 +++---
>  drivers/net/ethernet/amd/au1000_eth.c              |    4 ++--
>  drivers/net/ethernet/broadcom/bcm63xx_enet.c       |    4 ++--
>  drivers/net/ethernet/broadcom/sb1250-mac.c         |    6 ++---
>  drivers/net/ethernet/broadcom/tg3.c                |    4 ++--
>  drivers/net/ethernet/cadence/macb.c                |    4 ++--
>  drivers/net/ethernet/dnet.c                        |    6 ++---
>  drivers/net/ethernet/ethoc.c                       |    4 ++--
>  drivers/net/ethernet/faraday/ftgmac100.c           |    4 ++--
>  drivers/net/ethernet/freescale/fec.c               |    4 ++--
>  drivers/net/ethernet/freescale/fec_mpc52xx.c       |    5 ++--
>  .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    6 ++---
>  drivers/net/ethernet/freescale/gianfar.c           |    8 +++----
>  drivers/net/ethernet/freescale/ucc_geth.c          |    6 ++---
>  drivers/net/ethernet/lantiq_etop.c                 |    4 ++--
>  drivers/net/ethernet/nxp/lpc_eth.c                 |    5 ++--
>  drivers/net/ethernet/octeon/octeon_mgmt.c          |    4 ++--
>  drivers/net/ethernet/pasemi/pasemi_mac.c           |    4 ++--
>  drivers/net/ethernet/rdc/r6040.c                   |    4 ++--
>  drivers/net/ethernet/renesas/sh_eth.c              |    4 ++--
>  drivers/net/ethernet/s6gmac.c                      |    4 ++--
>  drivers/net/ethernet/smsc/smsc911x.c               |    4 ++--
>  drivers/net/ethernet/smsc/smsc9420.c               |    5 ++--
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    6 +++--
>  drivers/net/ethernet/ti/cpmac.c                    |    4 ++--
>  drivers/net/ethernet/ti/cpsw.c                     |    5 ++--
>  drivers/net/ethernet/ti/davinci_emac.c             |    4 ++--
>  drivers/net/ethernet/toshiba/tc35815.c             |    5 ++--
>  drivers/net/ethernet/xilinx/ll_temac_main.c        |    4 ++--
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |    3 ++-
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c      |    5 ++--
>  drivers/net/ethernet/xscale/ixp4xx_eth.c           |    4 ++--
>  drivers/net/phy/phy.c                              |   25
> ++++++++++++-------- drivers/net/phy/phy_device.c                    =
   |=20
>  23 +++++++++++------- drivers/of/of_mdio.c                          =
   =20
> |   24 ++++++++++++------- include/linux/of_mdio.h                   =
    =20
>    |   15 ++++++------ include/linux/phy.h                           =
   =20
> |   20 +++++++++------- 39 files changed, 149 insertions(+), 116
> deletions(-)

--=20
=46lorian
