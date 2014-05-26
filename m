From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 1/2] net/mlx4_core: Deprecate use_prio module
 parameter
Date: Mon, 26 May 2014 20:22:32 +0100
Message-ID: <1401132152.27743.2.camel@deadeye.wl.decadent.org.uk>
References: <1400488662-5657-1-git-send-email-amirv@mellanox.com>
	 <1400488662-5657-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xDmlOQxCgdlLeC6dlDPb"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Carol Soto <clsoto@linux.vnet.ibm.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54579 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751343AbaEZTXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 15:23:10 -0400
In-Reply-To: <1400488662-5657-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xDmlOQxCgdlLeC6dlDPb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-05-19 at 11:37 +0300, Amir Vadai wrote:
> It was used for steering by user priority for A0 steering. A0 mode is
> not supported anymore. Printing a message and ignoring the parameter.
>=20
> CC: Carol Soto <clsoto@linux.vnet.ibm.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c | 8 ++++----
>  include/linux/mlx4/device.h               | 1 -
>  2 files changed, 4 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethe=
rnet/mellanox/mlx4/main.c
> index a56f601..08ff5dd 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -132,8 +132,7 @@ MODULE_PARM_DESC(log_num_vlan, "Log2 max number of VL=
ANs per ETH port (0-7)");
> =20
>  static bool use_prio;
>  module_param_named(use_prio, use_prio, bool, 0444);

Perhaps the sysfs permissions should be set to 0 (i.e. not visible in
sysfs)?

> -MODULE_PARM_DESC(use_prio, "Enable steering by VLAN priority on ETH port=
s "
> -		  "(0/1, default 0)");
> +MODULE_PARM_DESC(use_prio, "Enable steering by VLAN priority on ETH port=
s (deprecated)");
>
>  int log_mtts_per_seg =3D ilog2(MLX4_MTT_ENTRY_PER_SEG);
>  module_param_named(log_mtts_per_seg, log_mtts_per_seg, int, 0444);
> @@ -290,7 +289,6 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct =
mlx4_dev_cap *dev_cap)
> =20
>  	dev->caps.log_num_macs  =3D log_num_mac;
>  	dev->caps.log_num_vlans =3D MLX4_LOG_NUM_VLANS;
> -	dev->caps.log_num_prios =3D use_prio ? 3 : 0;
> =20
>  	for (i =3D 1; i <=3D dev->caps.num_ports; ++i) {
>  		dev->caps.port_type[i] =3D MLX4_PORT_TYPE_NONE;
> @@ -358,7 +356,6 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct =
mlx4_dev_cap *dev_cap)
>  		dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_ADDR] =3D
>  		(1 << dev->caps.log_num_macs) *
>  		(1 << dev->caps.log_num_vlans) *
> -		(1 << dev->caps.log_num_prios) *
>  		dev->caps.num_ports;
>  	dev->caps.reserved_qps_cnt[MLX4_QP_REGION_FC_EXCH] =3D MLX4_NUM_FEXCH;
> =20
> @@ -2775,6 +2772,9 @@ static int __init mlx4_verify_params(void)
>  		pr_warning("mlx4_core: log_num_vlan - obsolete module param, using %d\=
n",
>  			   MLX4_LOG_NUM_VLANS);
> =20
> +	if (use_prio !=3D 0)
> +		pr_warn("mlx4_core: use_prio - obsolete module param, ignored\n");

You spell it pr_warning() in the adjacent logging statements.

Ben.

>  	if ((log_mtts_per_seg < 1) || (log_mtts_per_seg > 7)) {
>  		pr_warning("mlx4_core: bad log_mtts_per_seg: %d\n", log_mtts_per_seg);
>  		return -1;
> diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
> index c0468e6..ca38871 100644
> --- a/include/linux/mlx4/device.h
> +++ b/include/linux/mlx4/device.h
> @@ -449,7 +449,6 @@ struct mlx4_caps {
>  	int                     reserved_qps_base[MLX4_NUM_QP_REGION];
>  	int                     log_num_macs;
>  	int                     log_num_vlans;
> -	int                     log_num_prios;
>  	enum mlx4_port_type	port_type[MLX4_MAX_PORTS + 1];
>  	u8			supported_type[MLX4_MAX_PORTS + 1];
>  	u8                      suggested_type[MLX4_MAX_PORTS + 1];

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-xDmlOQxCgdlLeC6dlDPb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4OUg+e/yOyVhhEJAQqgXRAAqKG4y68AdL4OVdh62JCAsiLQLHMvL5vF
chUTOB5K8ilb2qXOWMlgQDW65AgIhRgCM4j7t/Yb3cBzPGIolto3vqUog/YGqNp5
mVa5csY3hiTQXXMXmTdb39wixVWO+MRlA6rt9z0hhFth9SLHtWLbChrYAywa6yQF
+qGCXkVxXnYwVzZ4dGLfJaL5qH0Jh8S5c3+Q9YoWcxeuyAigdmgxRqVisWrxyAn4
i+exGAdVEdwxasCXHC5QbJzf6TdouJkDp19brrGEQaxZZepOw/9BnJCt3jjq0i0t
FKb3MKOt5v3gvljq1hRSqjEzAn0BL3tCY5oKKr6cm4tYCj4G8j+7ORM7C/iNYvJX
c6ghQ4QbyUC0/aqXov6zsC7r8U9NSaUxthXJYkb0eBbT8ThZLXs430zPzGGA4yZE
1crvcr02H9owifQHKlM9mLSZhsNoNCLlrHCjuv/sYX6cfx+Q4g+DVK9dGEU2yl+c
w0Q9XaWi07+1qz8TUtcSO6GRJrXIVWiPrnUpYW+9+pPcFAC7iCzcXzc+r1PIFgUk
qTqKIgDco9Ck16drF4uzUt9MCD0eq3HMdKNL0qpm77eHKiIfPMlXBH1nzVvKGbw1
dnczL1k7B0hd7xHZdISalFAxwazPkLtxNW/1RH49GPNJwf9CKIc59HUcR4Dp6NEl
nujxM6VYHsk=
=Zxc5
-----END PGP SIGNATURE-----

--=-xDmlOQxCgdlLeC6dlDPb--
