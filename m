From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net v2 4/5] net: fsl/fman: fix fixed-link-phydev reference
 leak
Date: Fri, 25 Nov 2016 10:54:27 +0000
Message-ID: <AM4PR04MB16041ACDCDACF188B37E61F6EC890@AM4PR04MB1604.eurprd04.prod.outlook.com>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
 <1480011691-13278-5-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Johan Hovold <johan@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480011691-13278-5-git-send-email-johan@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Johan Hovold [mailto:jhovold@gmail.com] On Behalf Of Johan Hovold
> Sent: Thursday, November 24, 2016 8:22 PM
>=20
> Make sure to drop the reference taken by of_phy_find_device() when
> looking up a fixed-link phydev during probe.
>=20
> Fixes: 57ba4c9b56d8 ("fsl/fman: Add FMan MAC support")
> Signed-off-by: Johan Hovold <johan@kernel.org>
> ---
>  drivers/net/ethernet/freescale/fman/mac.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/freescale/fman/mac.c
> b/drivers/net/ethernet/freescale/fman/mac.c
> index 8fe6b3e253fa..736db9d9b0ad 100644
> --- a/drivers/net/ethernet/freescale/fman/mac.c
> +++ b/drivers/net/ethernet/freescale/fman/mac.c
> @@ -892,6 +892,8 @@ static int mac_probe(struct platform_device *_of_dev)
>  		priv->fixed_link->duplex =3D phy->duplex;
>  		priv->fixed_link->pause =3D phy->pause;
>  		priv->fixed_link->asym_pause =3D phy->asym_pause;
> +
> +		put_device(&phy->mdio.dev);
>  	}
>=20
>  	err =3D mac_dev->init(mac_dev);
> --
> 2.7.3

Thank you,
Madalin
