From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3/4] net: ethoc: implement ethtool get registers
Date: Thu, 30 Jan 2014 14:01:15 +0000
Message-ID: <1391090475.4405.60.camel@deadeye.wl.decadent.org.uk>
References: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
	 <1391025397-14965-4-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-JLnwgeMfi7hQ2xFEhuF8"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391025397-14965-4-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-JLnwgeMfi7hQ2xFEhuF8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-29 at 23:56 +0400, Max Filippov wrote:
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
>  drivers/net/ethernet/ethoc.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
> index 9518023..0bf297b 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -52,6 +52,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation si=
ze");
>  #define	ETH_HASH0	0x48
>  #define	ETH_HASH1	0x4c
>  #define	ETH_TXCTRL	0x50
> +#define	ETH_END		0x54
> =20
>  /* mode register */
>  #define	MODER_RXEN	(1 <<  0) /* receive enable */
> @@ -922,9 +923,28 @@ static int ethoc_set_settings(struct net_device *dev=
, struct ethtool_cmd *cmd)
>  	return phy_ethtool_sset(phydev, cmd);
>  }
> =20
> +static int ethoc_get_regs_len(struct net_device *netdev)
> +{
> +	return ETH_END;
> +}
> +
> +static void ethoc_get_regs(struct net_device *dev, struct ethtool_regs *=
regs,
> +			   void *p)
> +{
> +	struct ethoc *priv =3D netdev_priv(dev);
> +	u32 *regs_buff =3D p;
> +	unsigned i;
> +
> +	regs->version =3D 0;
> +	for (i =3D 0; i < ETH_END / sizeof(u32); ++i)
> +		regs_buff[i] =3D ethoc_read(priv, i * sizeof(u32));
> +}
> +
>  const struct ethtool_ops ethoc_ethtool_ops =3D {
>  	.get_settings =3D ethoc_get_settings,
>  	.set_settings =3D ethoc_set_settings,
> +	.get_regs_len =3D ethoc_get_regs_len,
> +	.get_regs =3D ethoc_get_regs,
>  	.get_link =3D ethtool_op_get_link,
>  	.get_ts_info =3D ethtool_op_get_ts_info,
>  };

--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert Einstein

--=-JLnwgeMfi7hQ2xFEhuF8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUupbK+e/yOyVhhEJAQpF3RAAuzw8YJRD4hb/4qXZsUv14Hf2TcJRHiCM
r6ynYjiX3rcEAGHnQp+hUmGbLRfz8tXxy6lA2DL1NSOjtbN8scC+Kmf+yRka0FB1
qRr5cVktKe4fCyM5SWCKtmH/a1GHKu/+DYjm93fqLd3TZzLT08nZ87bxXIsxGvf4
DDf/Onl8Sk2q9JTCymfc9Vj7avqrlfjJYPQLvCaTwUO6gpLFwHp50LVnwU9t7GVd
w/ZoFezMyds9cKBhuQ0Uw2/X7E5usKnVbjpK3RL202ScVp2Yf1S2grmiIdJt39/Z
Zk8Gvseb3FXy2+baIH5u+5HzbRsOgltrquSnsKDv0wlUaraowbSY3z5C4fH+NO4l
4cSglGQWCLvN51xiN+A4cJlQ9OXfrS8MUkvbU0MaJLL8RXdoIUo9VNFkIDdjEuCq
CpoH02defxfstdde4zZKK4q/U4kjM23Q4+AvpKv+fVlrMQ5PcOYKVTjD8s9Gn2gx
xFH+lT0AEdgRlkYc0rpKuPdcTp7myLCK2rPcNTFa3SYuagY1r/eGi5kQN8/NY+Fj
y6S2CCLrPUenZzL2qWSMW+qAT/IfSvStgIFT0n8tuXoJYznV7wuTQ7XRsWBHnI+O
rLfgm+CU5YngEplpWhyjyIYHSRUKUbRoR42hmG4vuOHRzvyInbmiDg9v+ULS9sbi
5C5KBL2gVzM=
=R8lE
-----END PGP SIGNATURE-----

--=-JLnwgeMfi7hQ2xFEhuF8--
