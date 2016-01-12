From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCHv2 1/2] remove redundant struct clk NULL checks
Date: Tue, 12 Jan 2016 16:25:58 +0100
Message-ID: <1452612358.3694.44.camel@pengutronix.de>
References: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
	 <1452611876-451-2-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	Nimrod Andy <B38611@freescale.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Stefan Agner <stefan@agner.ch>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Sascha Hauer <kernel@pengutronix.de>,
	Shawn Guo <shawnguo@kernel.org>
To: Lothar =?ISO-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452611876-451-2-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 12.01.2016, 16:17 +0100 schrieb Lothar Wa=C3=9Fmann:
> NULL is a valid argument to clk_enable()/clk_disable(). Remove
> redundant checks before calling those functions.
>=20
> Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>

Reviewed-by: Lucas Stach <l.stach@pengutronix.de>

> ---
>  drivers/net/ethernet/freescale/fec_main.c | 23 +++++++++------------=
--
>  1 file changed, 9 insertions(+), 14 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/=
ethernet/freescale/fec_main.c
> index 502da6f..592a7a4 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1874,35 +1874,30 @@ static int fec_enet_clk_enable(struct net_dev=
ice *ndev, bool enable)
>  			}
>  			mutex_unlock(&fep->ptp_clk_mutex);
>  		}
> -		if (fep->clk_ref) {
> -			ret =3D clk_prepare_enable(fep->clk_ref);
> -			if (ret)
> -				goto failed_clk_ref;
> -		}
> +
> +		ret =3D clk_prepare_enable(fep->clk_ref);
> +		if (ret)
> +			goto failed_clk_ref;
>  	} else {
>  		clk_disable_unprepare(fep->clk_ahb);
> -		if (fep->clk_enet_out)
> -			clk_disable_unprepare(fep->clk_enet_out);
> +		clk_disable_unprepare(fep->clk_enet_out);
>  		if (fep->clk_ptp) {
>  			mutex_lock(&fep->ptp_clk_mutex);
>  			clk_disable_unprepare(fep->clk_ptp);
>  			fep->ptp_clk_on =3D false;
>  			mutex_unlock(&fep->ptp_clk_mutex);
>  		}
> -		if (fep->clk_ref)
> -			clk_disable_unprepare(fep->clk_ref);
> +		clk_disable_unprepare(fep->clk_ref);
>  	}
> =20
>  	return 0;
> =20
>  failed_clk_ref:
> -	if (fep->clk_ref)
> -		clk_disable_unprepare(fep->clk_ref);
> +	clk_disable_unprepare(fep->clk_ref);
>  failed_clk_ptp:
> -	if (fep->clk_enet_out)
> -		clk_disable_unprepare(fep->clk_enet_out);
> +	clk_disable_unprepare(fep->clk_enet_out);
>  failed_clk_enet_out:
> -		clk_disable_unprepare(fep->clk_ahb);
> +	clk_disable_unprepare(fep->clk_ahb);
> =20
>  	return ret;
>  }

--=20
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |
