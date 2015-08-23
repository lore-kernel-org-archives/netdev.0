From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/9] dsa: mv88e6xxx: Set the RGMII delay based
 on phy interface
Date: Sun, 23 Aug 2015 11:44:01 -0700
Message-ID: <55DA1471.2080905@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-7-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35067 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbbHWSoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:44:04 -0400
Received: by obbwr7 with SMTP id wr7so96325922obb.2
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:44:02 -0700 (PDT)
In-Reply-To: <1440323220-20438-7-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
> Some Marvell switches allow the RGMII Rx and Tx clock to be delayed
> when the port is using RGMII. Have the adjust_link function look at
> the phy interface type and enable this delay as requested.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 10 ++++++++++
>  drivers/net/dsa/mv88e6xxx.h |  2 ++
>  2 files changed, 12 insertions(+)
>=20
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.=
c
> index 7901db6503b4..f5af368751b2 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -612,6 +612,16 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds=
, int port,
>  	if (phydev->duplex =3D=3D DUPLEX_FULL)
>  		reg |=3D PORT_PCS_CTRL_DUPLEX_FULL;
> =20
> +	if ((mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds)) &&
> +	    (port >=3D ps->num_ports - 2)) {

Are we positive that the last two ports of a switch are going to be
RGMII capable or is this something that should be moved to Device Tree =
/
platform data to account for different switch families? Maybe having a
bitmask of RGMII capable ports stored in "ps" would be good enough?

> +		if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_RXID)
> +			reg |=3D PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
> +		if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_TXID)
> +			reg |=3D PORT_PCS_CTRL_RGMII_DELAY_TXCLK;
> +		if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID)
> +			reg |=3D (PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
> +				PORT_PCS_CTRL_RGMII_DELAY_TXCLK);
> +	}
>  	_mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_PCS_CTRL, reg);
> =20
>  out:
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.=
h
> index 79003c55fe62..9b6f3d9d5ae1 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -46,6 +46,8 @@
>  #define PORT_STATUS_TX_PAUSED	BIT(5)
>  #define PORT_STATUS_FLOW_CTRL	BIT(4)
>  #define PORT_PCS_CTRL		0x01
> +#define PORT_PCS_CTRL_RGMII_DELAY_RXCLK	BIT(15)
> +#define PORT_PCS_CTRL_RGMII_DELAY_TXCLK	BIT(14)
>  #define PORT_PCS_CTRL_FC		BIT(7)
>  #define PORT_PCS_CTRL_FORCE_FC		BIT(6)
>  #define PORT_PCS_CTRL_LINK_UP		BIT(5)
>=20


--=20
=46lorian
