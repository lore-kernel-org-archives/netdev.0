From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 2/2] fec: don't enable irqs in hard irq context
Date: Thu, 03 Sep 2009 11:14:24 +1000
Message-ID: <4A9F1870.7070408@snapgear.com>
References: <20090831132200.GA21836@pengutronix.de> <1251882856-23549-1-git-send-email-u.kleine-koenig@pengutronix.de> <1251882856-23549-2-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rt-users@vger.kernel.org,
	Ben Hutchings <ben@decadent.org.uk>,
	Patrick McHardy <kaber@trash.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Matt Waddel <Matt.Waddel@freescale.com>,
	netdev@vger.kernel.org,
	Tim Sander <tim01@vlsi.informatik.tu-darmstadt.de>
To: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1251882856-23549-2-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe,

Uwe Kleine-K=C3=B6nig wrote:
> fec_enet_mii, fec_enet_rx and fec_enet_tx are both only called by
> fec_enet_interrupt in interrupt context.  So they must not use
> spin_lock_irq/spin_unlock_irq.
>=20
> This fixes:
> 	WARNING: at kernel/lockdep.c:2140 trace_hardirqs_on_caller+0x130/0x1=
94()
> 	...
>=20
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> Cc: Greg Ungerer <gerg@uclinux.org>

Looks good.

Acked-by: Greg Ungerer <gerg@uclinux.org>


> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Sascha Hauer <s.hauer@pengutronix.de>
> Cc: Matt Waddel <Matt.Waddel@freescale.com>
> Cc: netdev@vger.kernel.org
> Cc: Tim Sander <tim01@vlsi.informatik.tu-darmstadt.de>
> ---
>  drivers/net/fec.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index ef82606..9c49d56 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -427,7 +427,7 @@ fec_enet_tx(struct net_device *dev)
>  	struct	sk_buff	*skb;
> =20
>  	fep =3D netdev_priv(dev);
> -	spin_lock_irq(&fep->hw_lock);
> +	spin_lock(&fep->hw_lock);
>  	bdp =3D fep->dirty_tx;
> =20
>  	while (((status =3D bdp->cbd_sc) & BD_ENET_TX_READY) =3D=3D 0) {
> @@ -486,7 +486,7 @@ fec_enet_tx(struct net_device *dev)
>  		}
>  	}
>  	fep->dirty_tx =3D bdp;
> -	spin_unlock_irq(&fep->hw_lock);
> +	spin_unlock(&fep->hw_lock);
>  }
> =20
> =20
> @@ -509,7 +509,7 @@ fec_enet_rx(struct net_device *dev)
>  	flush_cache_all();
>  #endif
> =20
> -	spin_lock_irq(&fep->hw_lock);
> +	spin_lock(&fep->hw_lock);
> =20
>  	/* First, grab all of the stats for the incoming packet.
>  	 * These get messed up if we get called due to a busy condition.
> @@ -604,7 +604,7 @@ rx_processing_done:
>  	}
>  	fep->cur_rx =3D bdp;
> =20
> -	spin_unlock_irq(&fep->hw_lock);
> +	spin_unlock(&fep->hw_lock);
>  }
> =20
>  /* called from interrupt context */
> @@ -615,7 +615,7 @@ fec_enet_mii(struct net_device *dev)
>  	mii_list_t	*mip;
> =20
>  	fep =3D netdev_priv(dev);
> -	spin_lock_irq(&fep->mii_lock);
> +	spin_lock(&fep->mii_lock);
> =20
>  	if ((mip =3D mii_head) =3D=3D NULL) {
>  		printk("MII and no head!\n");
> @@ -633,7 +633,7 @@ fec_enet_mii(struct net_device *dev)
>  		writel(mip->mii_regval, fep->hwp + FEC_MII_DATA);
> =20
>  unlock:
> -	spin_unlock_irq(&fep->mii_lock);
> +	spin_unlock(&fep->mii_lock);
>  }
> =20
>  static int

--=20
-----------------------------------------------------------------------=
