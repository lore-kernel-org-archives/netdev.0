From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [FIX] ARM: IXP4xx Ethernet NAPI fix
Date: Fri, 11 Jul 2008 10:04:13 -0400
Message-ID: <4877685D.1030503@garzik.org>
References: <m31w23ia8n.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759721AbYGKOEb@vger.kernel.org>
In-Reply-To: <m31w23ia8n.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> This patch removes some weirdness from IXP4xx Ethernet driver.
> Ideally it should go in 2.6.26 though it's not that critical. Thanks.
>=20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>
>=20
> diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_et=
h.c
> index c617b64..9b777d9 100644
> --- a/drivers/net/arm/ixp4xx_eth.c
> +++ b/drivers/net/arm/ixp4xx_eth.c
> @@ -522,7 +522,6 @@ static int eth_poll(struct napi_struct *napi, int=
 budget)
>  #endif
> =20
>  		if ((n =3D queue_get_desc(rxq, port, 0)) < 0) {
> -			received =3D 0; /* No packet received */
>  #if DEBUG_RX
>  			printk(KERN_DEBUG "%s: eth_poll netif_rx_complete\n",
>  			       dev->name);
> @@ -543,7 +542,7 @@ static int eth_poll(struct napi_struct *napi, int=
 budget)
>  			printk(KERN_DEBUG "%s: eth_poll all done\n",
>  			       dev->name);
>  #endif
> -			return 0; /* all work done */
> +			return received; /* all work done */

applied
