From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 1/4] can: dev: Add support for limiting configured
 bitrate
Date: Thu, 10 Aug 2017 17:29:13 +0200
Message-ID: <4a96c6a8-b8c5-24a1-5e99-44751a0ae987@pengutronix.de>
References: <20170810005916.27163-1-fcooper@ti.com>
 <20170810005916.27163-2-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="mMhkTxquGB5jERDiHjS8tXtRJOWrPlaQf"
To: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org, sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
        socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170810005916.27163-2-fcooper-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mMhkTxquGB5jERDiHjS8tXtRJOWrPlaQf
Content-Type: multipart/mixed; boundary="2H0fqbPv56hvmkDXmofDteMS09jVhdKAu";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
 quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org,
 andrew-g2DYL2Zd6BY@public.gmane.org, sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org, socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org
Message-ID: <4a96c6a8-b8c5-24a1-5e99-44751a0ae987-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 1/4] can: dev: Add support for limiting configured
 bitrate
References: <20170810005916.27163-1-fcooper-l0cyMroinI0@public.gmane.org>
 <20170810005916.27163-2-fcooper-l0cyMroinI0@public.gmane.org>
In-Reply-To: <20170810005916.27163-2-fcooper-l0cyMroinI0@public.gmane.org>

--2H0fqbPv56hvmkDXmofDteMS09jVhdKAu
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: quoted-printable

Hello,

sorry for stepping in late....

On 08/10/2017 02:59 AM, Franklin S Cooper Jr wrote:
> Various CAN or CAN-FD IP may be able to run at a faster rate than
> what the transceiver the CAN node is connected to. This can lead to
> unexpected errors. However, CAN transceivers typically have fixed
> limitations and provide no means to discover these limitations at
> runtime. Therefore, add support for a can-transceiver node that
> can be reused by other CAN peripheral drivers to determine for both
> CAN and CAN-FD what the max bitrate that can be used. If the user
> tries to configure CAN to pass these maximum bitrates it will throw
> an error.
>=20
> Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
> ---
> Version 4 changes:
> Used can-transceiver instead of fixed-transceiver.
>=20
>  drivers/net/can/dev.c   | 50 +++++++++++++++++++++++++++++++++++++++++=
++++++++
>  include/linux/can/dev.h |  5 +++++
>  2 files changed, 55 insertions(+)
>=20
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index 365a8cc..372108f 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -27,6 +27,7 @@
>  #include <linux/can/skb.h>
>  #include <linux/can/netlink.h>
>  #include <linux/can/led.h>
> +#include <linux/of.h>
>  #include <net/rtnetlink.h>
> =20
>  #define MOD_DESC "CAN device driver interface"
> @@ -814,6 +815,39 @@ int open_candev(struct net_device *dev)
>  }
>  EXPORT_SYMBOL_GPL(open_candev);
> =20
> +#ifdef CONFIG_OF
> +/*
> + * Common function that can be used to understand the limitation of
> + * a transceiver when it provides no means to determine these limitati=
ons
> + * at runtime.
> + */
> +void of_can_transceiver(struct net_device *dev)
> +{
> +	struct device_node *dn;
> +	struct can_priv *priv =3D netdev_priv(dev);
> +	struct device_node *np;
> +	unsigned int max_bitrate;
> +	int ret;
> +
> +	np =3D dev->dev.parent->of_node;
> +
> +	dn =3D of_get_child_by_name(np, "can-transceiver");
> +	if (!dn)
> +		return;
> +
> +	max_bitrate =3D 0;
> +	ret =3D of_property_read_u32(dn, "max-bitrate", &max_bitrate);

IIRC the last argument is only modified in case of no error, so what abou=
t:
	ret =3D of_property_read_u32(dn, "max-bitrate",
			&priv->max_bitrate);

> +
> +	if (max_bitrate > 0) {
> +		priv->max_bitrate =3D max_bitrate;
> +		priv->is_bitrate_limited =3D true;

Do we need is_bitrate_limited...

> +	} else if (ret !=3D -EINVAL) {
> +		netdev_warn(dev, "Invalid value for transceiver max bitrate\n");
> +	}
> +}
> +EXPORT_SYMBOL(of_can_transceiver);
> +#endif
> +
>  /*
>   * Common close function for cleanup before the device gets closed.
>   *
> @@ -913,6 +947,14 @@ static int can_changelink(struct net_device *dev, =
struct nlattr *tb[],
>  					priv->bitrate_const_cnt);
>  		if (err)
>  			return err;
> +
> +		if (priv->is_bitrate_limited &&
> +		    bt.bitrate > priv->max_bitrate) {

=2E..can we just use priv->max_bitrate?

	if (priv->max_bitrate && bt.bitrate > priv->max_bitrate)

> +			netdev_err(dev, "arbitration bitrate surpasses transceiver capabili=
ties of %d bps\n",
> +				   priv->max_bitrate);
> +			return -EINVAL;
> +		}
> +
>  		memcpy(&priv->bittiming, &bt, sizeof(bt));
> =20
>  		if (priv->do_set_bittiming) {
> @@ -997,6 +1039,14 @@ static int can_changelink(struct net_device *dev,=
 struct nlattr *tb[],
>  					priv->data_bitrate_const_cnt);
>  		if (err)
>  			return err;
> +
> +		if (priv->is_bitrate_limited &&
> +		    dbt.bitrate > priv->max_bitrate) {
> +			netdev_err(dev, "canfd data bitrate surpasses transceiver capabilit=
ies of %d bps\n",
> +				   priv->max_bitrate);
> +			return -EINVAL;
> +		}
> +
>  		memcpy(&priv->data_bittiming, &dbt, sizeof(dbt));
> =20
>  		if (priv->do_set_data_bittiming) {
> diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
> index 141b05a..5519f59 100644
> --- a/include/linux/can/dev.h
> +++ b/include/linux/can/dev.h
> @@ -47,6 +47,9 @@ struct can_priv {
>  	unsigned int data_bitrate_const_cnt;
>  	struct can_clock clock;
> =20
> +	unsigned int max_bitrate;
> +	bool is_bitrate_limited;
> +
>  	enum can_state state;
> =20
>  	/* CAN controller features - see include/uapi/linux/can/netlink.h */
> @@ -165,6 +168,8 @@ void can_put_echo_skb(struct sk_buff *skb, struct n=
et_device *dev,
>  unsigned int can_get_echo_skb(struct net_device *dev, unsigned int idx=
);
>  void can_free_echo_skb(struct net_device *dev, unsigned int idx);
> =20
> +void of_can_transceiver(struct net_device *dev);
> +
>  struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame=
 **cf);
>  struct sk_buff *alloc_canfd_skb(struct net_device *dev,
>  				struct canfd_frame **cfd);
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--2H0fqbPv56hvmkDXmofDteMS09jVhdKAu--

--mMhkTxquGB5jERDiHjS8tXtRJOWrPlaQf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlmMe8kACgkQHv7KIOw4
HPbtKggAltn42+XOFBPtjBR0Zdf948NmpxpxAKtGVvnHjVuOE10m5M2GVFftg2Dm
7ewHJj/G72bfN/V1VpBvljCuWnqzoFPWwZwPU4R7kPrZku2LEHfv7wq9M2f8nN8n
JJB9oITPPFqaYhoAWQWodJWFtlFXellUxZc7fjmsY1DlzWQyCrxvkEpd8afSfD1U
CZOfp7kkGYqloeVeCUcjSL4D+rr4ljMKxXYW/p1ftsoT2Zz0/ddfTrUY03DMTEBN
N1RblAXo6lGbNXowNF2uLO7w+y9FXIYOhUeZCJYT5PeL01Ebz2RuYWWyYWQXA8v0
wJXZwsClX8KzdKnAngQ6oI9KkssoIQ==
=sBn7
-----END PGP SIGNATURE-----

--mMhkTxquGB5jERDiHjS8tXtRJOWrPlaQf--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
