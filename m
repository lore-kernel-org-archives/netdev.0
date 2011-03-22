From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 4/4] drivers/net/fec: Don't mess with configured MAC
 addresses.
Date: Tue, 22 Mar 2011 20:33:17 +0800
Message-ID: <20110322123316.GH28098@S2100-06.ap.freescale.net>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
 <e7cec31bec3eb7dad56688c4390a59f99625ea83.1300724245.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <u.kleine-koenig@pengutronix.de>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.185]:47128
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755762Ab1CVMci convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 08:32:38 -0400
Content-Disposition: inline
In-Reply-To: <e7cec31bec3eb7dad56688c4390a59f99625ea83.1300724245.git.LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 11:00:02AM +0100, Lothar Wa=DFmann wrote:
> The FEC driver currently uses the MAC address assigned to the first
> interface incremented by one for the second interface.
>=20
> Change this to be able to configure distinct MAC addresses via
> platform_data.
>=20
> Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>

Acked-by: <shawn.guo@freescale.com>

--=20
Regards,
Shawn

> ---
>  drivers/net/fec.c |    9 ++-------
>  1 files changed, 2 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 3666524..9d89e99 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -736,7 +736,7 @@ static void __inline__ fec_get_mac(struct net_dev=
ice *ndev)
>  {
>  	struct fec_enet_private *fep =3D netdev_priv(ndev);
>  	struct fec_platform_data *pdata =3D fep->pdev->dev.platform_data;
> -	unsigned char *iap, tmpaddr[ETH_ALEN];
> +	unsigned char iap[ETH_ALEN], tmpaddr[ETH_ALEN];
> =20
>  	/*
>  	 * try to get mac address in following order:
> @@ -744,7 +744,10 @@ static void __inline__ fec_get_mac(struct net_de=
vice *ndev)
>  	 * 1) module parameter via kernel command line in form
>  	 *    fec.macaddr=3D0x00,0x04,0x9f,0x01,0x30,0xe0
>  	 */
> -	iap =3D macaddr;
> +	if (fep->pdev->id =3D=3D 0)
> +		memcpy(iap, macaddr, ETH_ALEN);
> +	else
> +		memset(iap, 0, ETH_ALEN);
> =20
>  	/*
>  	 * 2) from flash or fuse (via platform data)
> @@ -767,14 +770,10 @@ static void __inline__ fec_get_mac(struct net_d=
evice *ndev)
>  			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
>  		*((unsigned short *) &tmpaddr[4]) =3D
>  			be16_to_cpu(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
> -		iap =3D &tmpaddr[0];
> +		memcpy(iap, tmpaddr, ETH_ALEN);
>  	}
> =20
>  	memcpy(ndev->dev_addr, iap, ETH_ALEN);
> -
> -	/* Adjust MAC if using macaddr */
> -	if (iap =3D=3D macaddr)
> -		 ndev->dev_addr[ETH_ALEN-1] =3D macaddr[ETH_ALEN-1] + fep->pdev->i=
d;
>  }
> =20
>  /* -----------------------------------------------------------------=
-------- */
> --=20
> 1.5.6.5
>=20

