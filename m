From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 1/6] net: davinci_emac: Fix hangs with interrupts
Date: Tue, 13 Jan 2015 13:36:34 -0600
Message-ID: <20150113193634.GQ16533@saruman>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-2-git-send-email-tony@atomide.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VdnGiXwuH6t1Tqzo"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1421177368-19756-2-git-send-email-tony@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--VdnGiXwuH6t1Tqzo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 13, 2015 at 11:29:23AM -0800, Tony Lindgren wrote:
> On davinci_emac, we have pulse interrupts. This means that we need to
> clear the EOI bits when disabling interrupts as otherwise the interrupts
> keep happening. And we also need to not clear the EOI bits again when
> enabling the interrupts as otherwise we will get tons of:
>=20
> unexpected IRQ trap at vector 00
>=20
> These errors almost certainly mean that the omap-intc.c is signaling
> a spurious interrupt with the reserved irq 127 as we've seen earlier
> on omap3.
>=20
> Let's fix the issue by clearing the EOI bits when disabling the
> interrupts. Let's also keep the comment for "Rx Threshold and Misc
> interrupts are not enabled" for both enable and disable so people
> are aware of this when potentially adding more support.
>=20
> Note that eventually we should handle the RX and TX interrupts
> separately like cpsw is now doing. However, so far I have not seen
> any issues with this based on my testing, so it seems to behave a
> little different compared to the cpsw that had a similar issue.
>=20
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Cc: Felipe Balbi <balbi@ti.com>

pretty much the same thing that happens with CPSW, I think that a future
patch might want to change things so that we only write EOI to the IRQ
that actually fires, though.

Reviewed-by: Felipe Balbi <balbi@ti.com>

> Signed-off-by: Tony Lindgren <tony@atomide.com>
> ---
>  drivers/net/ethernet/ti/davinci_emac.c | 19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/etherne=
t/ti/davinci_emac.c
> index ea71251..383ed52 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -922,6 +922,16 @@ static void emac_int_disable(struct emac_priv *priv)
>  		if (priv->int_disable)
>  			priv->int_disable();
> =20
> +		/* NOTE: Rx Threshold and Misc interrupts are not enabled */
> +
> +		/* ack rxen only then a new pulse will be generated */
> +		emac_write(EMAC_DM646X_MACEOIVECTOR,
> +			EMAC_DM646X_MAC_EOI_C0_RXEN);
> +
> +		/* ack txen- only then a new pulse will be generated */
> +		emac_write(EMAC_DM646X_MACEOIVECTOR,
> +			EMAC_DM646X_MAC_EOI_C0_TXEN);
> +
>  		local_irq_restore(flags);
> =20
>  	} else {
> @@ -951,15 +961,6 @@ static void emac_int_enable(struct emac_priv *priv)
>  		 * register */
> =20
>  		/* NOTE: Rx Threshold and Misc interrupts are not enabled */
> -
> -		/* ack rxen only then a new pulse will be generated */
> -		emac_write(EMAC_DM646X_MACEOIVECTOR,
> -			EMAC_DM646X_MAC_EOI_C0_RXEN);
> -
> -		/* ack txen- only then a new pulse will be generated */
> -		emac_write(EMAC_DM646X_MACEOIVECTOR,
> -			EMAC_DM646X_MAC_EOI_C0_TXEN);
> -
>  	} else {
>  		/* Set DM644x control registers for interrupt control */
>  		emac_ctrl_write(EMAC_CTRL_EWCTL, 0x1);
> --=20
> 2.1.4
>=20

--=20
balbi

--VdnGiXwuH6t1Tqzo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtXPCAAoJEIaOsuA1yqRE7OAP/2nmZZZCJCdg+t0qwVL7rYJ9
mkLjxHsxdt47FvJz2Oxs6DZICXt5Gk7w8QlgcZC86jQGMzZCqkLE5XF9qdZKwciR
YL2J4Nh04eIl/mRwMvt6HnhuGFewyPEeUx5Sa03Hwj/aQIyKRtqar0MF4W8bxJZK
5PhPHAS+Ql5I6d2Ejf/MH6ZsYYTueHmWAby9+tmE9gQWmI//OEvU9ZUzHrwanlEi
kPFPogRJDcvXiB6A+j/4XP3kzyjU2bKu5NeL3/yM3gCIwEGf7azz8vMrQ5T6vaTu
1PGAQ8HDhnzD48apGz8OnF6IpEJAJf/aUX9lD/ASj15XHrvl76tKzjPdFzcpQmIp
S2561wMu344K18x3TmE44UAuaa4ck125G+O2wS8UVQxaeE3d7vncaftd3iAmyqJC
Tf8/LUBZpk2CIHJ1iZKQU2NKxK8RzxTcwbGaYYY1OJPkBsWbRh0Wa+hK8xo9v9Yn
pLBRG3IXaXpuPbCqktxQ3MULb8SGrX/e78rA6/x588AE/RTBaOUAIdMDQ6eEq7K0
Mu8WmYOxziWm2y50Rq8Imre3nYxPOpwcLg/9AC/dlG8IvRYERQJ+cFenHFFA1kRe
x5Gbx6Weo+cSLBAD7cEnvSVrCdKdB4HLJEteoagzrDFw8jcTdFYN4+jWv3ldfgTH
SNgsMGKavWT6b9Yglima
=SRFa
-----END PGP SIGNATURE-----

--VdnGiXwuH6t1Tqzo--
