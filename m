From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 4/4] drivers/net/fec: Don't mess with configured MAC
 addresses.
Date: Tue, 22 Mar 2011 15:43:37 +0800
Message-ID: <20110322074336.GE28098@S2100-06.ap.freescale.net>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
 <a6ba75577552abe8d5045434030c276d5f45779a.1300724245.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <u.kleine-koenig@pengutronix.de>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.181]:48412
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755014Ab1CVHnA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 03:43:00 -0400
Content-Disposition: inline
In-Reply-To: <a6ba75577552abe8d5045434030c276d5f45779a.1300724245.git.LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2011 at 05:37:36PM +0100, Lothar Wa=DFmann wrote:
> The FEC driver currently uses the MAC address assigned to the first
> interface incremented by one for the second interface.
>=20
> Change this to be able to configure distinct MAC addresses via
> platform_data.
>=20
> Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
> ---
>  drivers/net/fec.c |    9 ++-------
>  1 files changed, 2 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 3666524..9d89e99 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -750,13 +750,12 @@ static void __inline__ fec_get_mac(struct net_d=
evice *ndev)
>  	/*
>  	 * 2) from flash or fuse (via platform data)
>  	 */
> +	if (pdata)
> +		memcpy(iap, pdata->mac, ETH_ALEN);
>  	if (!is_valid_ether_addr(iap)) {
>  #ifdef CONFIG_M5272
>  		if (FEC_FLASHMAC)
>  			iap =3D (unsigned char *)FEC_FLASHMAC;
> -#else
> -		if (pdata)
> -			memcpy(iap, pdata->mac, ETH_ALEN);
>  #endif
>  	}
> =20
> @@ -772,10 +771,6 @@ static void __inline__ fec_get_mac(struct net_de=
vice *ndev)
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
>=20
NAK.

The 'mac' was designed as an optional member of fec
platform_data, as some platforms may not be able to provide it. This
patch breaks the order of getting mac, and will not work on the
platform that does not provide an valid mac with either platform_data
or controller mac registers, even there may be one in the kernel
command line.

The existing code takes mac address from kernel command line as the
first choice, and only falls through on other options when it's
invalid/unavailable.  So an valid mac from  kernel command line will
always get fec work anyway.

--=20
Regards,
Shawn

