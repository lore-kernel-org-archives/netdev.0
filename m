From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: don't
 munge MAC address from platform data
Date: Tue, 6 Dec 2011 14:48:58 +0200
Message-ID: <20111206124857.GB14048@sapphire.tkos.co.il>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Shawn Guo <shawn.guo@linaro.org>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Lothar,

On Tue, Dec 06, 2011 at 11:27:13AM +0100, Lothar Wa=DFmann wrote:
> When the MAC address is supplied via platform_data it should be OK as
> it is and should not be modified in case of a dual FEC setup.
> Also copying the MAC from platform_data to the single 'macaddr'
> variable will overwrite the MAC for the first interface in case of a
> dual FEC setup.
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

Since pdata might point to __initdata struct, you must hold a copy of i=
ts=20
content.

baruch

>  #endif
>  	}
> =20
> --=20

--=20
                                                     ~. .~   Tk Open Sy=
stems
=3D}------------------------------------------------ooO--U--Ooo--------=
----{=3D
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
