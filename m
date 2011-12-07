From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: don't
 munge MAC address from platform data
Date: Wed, 7 Dec 2011 16:49:54 +0800
Message-ID: <20111207084953.GD5550@S2100-06.ap.freescale.net>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 06, 2011 at 11:27:13AM +0100, Lothar Wa=DFmann wrote:
> When the MAC address is supplied via platform_data it should be OK as
> it is and should not be modified in case of a dual FEC setup.
> Also copying the MAC from platform_data to the single 'macaddr'
> variable will overwrite the MAC for the first interface in case of a
> dual FEC setup.

Hmm, I do not follow that.  If 'macaddr' holds a valid mac address,
the code path has no chance to be hit at all.  Otherwise, 'macaddr'
is just a place holder for copying mac address from pdata, in which
case the mac address will be fixed up at the end of the function for
dual FEC setup.

Regards,
Shawn

>=20
> Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
> ---
>  drivers/net/ethernet/freescale/fec.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ether=
net/freescale/fec.c
> index e2b5ce6..11534b9 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -818,7 +818,7 @@ static void __inline__ fec_get_mac(struct net_dev=
ice *ndev)
>  			iap =3D (unsigned char *)FEC_FLASHMAC;
>  #else
>  		if (pdata)
> -			memcpy(iap, pdata->mac, ETH_ALEN);
> +			iap =3D (unsigned char *)&pdata->mac;
>  #endif
>  	}
> =20
> --=20
> 1.5.6.5
