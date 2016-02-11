From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH 3/5] net/mlx4: fix some error handling in
 mlx4_multi_func_init()
Date: Thu, 11 Feb 2016 11:02:10 -0500
Message-ID: <56BCB082.4030701@redhat.com>
References: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
 <1455048677-19882-4-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="6CtGDLX8xG9kQD68FaNV7IHKnhQBqTMQL"
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Yishai Hadas <yishaih@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455048677-19882-4-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6CtGDLX8xG9kQD68FaNV7IHKnhQBqTMQL
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/09/2016 03:11 PM, Rasmus Villemoes wrote:
> The while loop after err_slaves should use post-decrement; otherwise
> we'll fail to do the kfrees for i=3D=3D0, and will run into out-of-boun=
ds
> accesses if the setup above failed already at i=3D=3D0.
>=20
> The predecrement in the --port is ok, since ->vlan_filter is
> (bizarrely) 1-indexed. But I'm changing 'if' to 'while' since it's a
> bit ugly to rely on MLX4_MAX_PORTS being 2.
>=20
> [I'm not sure why one even bothers populating the ->vlan_filter array:
> mlx4.h isn't #included by anything outside
> drivers/net/ethernet/mellanox/mlx4/, and "git grep -C2 -w vlan_filter
> drivers/net/ethernet/mellanox/mlx4/" seems to suggest that the
> vlan_filter elements aren't used at all.]
>=20
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cmd.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/eth=
ernet/mellanox/mlx4/cmd.c
> index d48d5793407d..bfe8234abbba 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -2369,7 +2369,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
>  					kzalloc(sizeof(struct mlx4_vlan_fltr),
>  						GFP_KERNEL);
>  				if (!s_state->vlan_filter[port]) {
> -					if (--port)
> +					while (--port)
>  						kfree(s_state->vlan_filter[port]);
>  					goto err_slaves;
>  				}
> @@ -2429,7 +2429,7 @@ err_thread:
>  	flush_workqueue(priv->mfunc.master.comm_wq);
>  	destroy_workqueue(priv->mfunc.master.comm_wq);
>  err_slaves:
> -	while (--i) {
> +	while (i--) {
>  		for (port =3D 1; port <=3D MLX4_MAX_PORTS; port++)
>  			kfree(priv->mfunc.master.slave_state[i].vlan_filter[port]);
>  	}
>=20

I'm modifying your patch slightly (dropping the first hunk, it isn't
really necessary as Yishai pointed out in review) and adjusting the
description to compensate.  I'll apply the result to my next for-rc serie=
s.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--6CtGDLX8xG9kQD68FaNV7IHKnhQBqTMQL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWvLCCAAoJELgmozMOVy/dKSAP/iVuuwBs4zyk6ZZGQiqZ0+a+
QoUw8M7aj7MOEs25qMLxVCiQRzsRpgHp1zfGxyUmHXX3LyxpxwIqeFfhN4Ycxc4l
0lO4Z/xxRX2aT0Nvgg+R6oPq6RgaOIlSAZ5WU2cCOSUZvrYXPRfuIa5czhQee+/m
UHkcBgSm+TxrgwMLwm9GKa8T/WZ7Pf9IeZhkhBKu+Z314wthuwPEZkw9e3Jj3TN0
Fa0TWPLRNeYTlOSw4FZz49TYvuoVDRZEtHeH0kgC/lXiB7AtRs78FYObNunJb8CU
tDEfubAyl3jImPpOKM/hT074kOpyem1o7tWHlOPmOMNRRv1mGbLsZ+13a1y/TkPj
+7he4felQAO7U1Xb4xskYx6xcRZVkLNAgywiIP5XtKJMBogu0WWCPu18eBqvTaUt
CZ0W+u8FJ7VeIuEXKX3d/3Qo4omWgwS8kkzgs/Tf1yFaLdM4RHbm5lidxik18V4P
kwJCZDggX4S6DBWBxfsaBXcFL9kTF60ym++Mwl/yWfXNNEo49xjKzL1im5GC20S0
Npsp1gAUFd6JZFd4HbtUdlbsV0nFotlnIGPeS3SzcvuHsGFjDxYVK4fkst8yDZQ2
cefUst/Cag/L4SeZPj8dW+KZXwaJQhTiUEOdxIY7L3xb3UGfNrCaUQZ0Ij8YLT69
IxuLaRW6M/PEAy7GWDfl
=nPkL
-----END PGP SIGNATURE-----

--6CtGDLX8xG9kQD68FaNV7IHKnhQBqTMQL--
