From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] net/mlx5_core/health: Remove deprecated
 create_singlethread_workqueue
Date: Sun, 17 Jul 2016 08:13:27 +0300
Message-ID: <20160717051327.GA20674@leon.nu>
References: <20160716075920.GA4547@Karyakshetra>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160716075920.GA4547@Karyakshetra>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 16, 2016 at 01:29:20PM +0530, Bhaktipriya Shridhar wrote:
> The workqueue health->wq was used as per device private health thread.
> This was done so that system error handling could be processed
> concurrently.

Not exactly, AFAIK it was intended to perform delayed work and not
relevant to concurrency.

> The workqueue has a single workitem(&health->work) and
> hence doesn't require ordering. It is involved in handling the health of
> the deviceand is not being used on a memory reclaim path.
> Hence, the singlethreaded workqueue has been replaced with the use of
> system_wq.

Yes

>=20
> System workqueues have been able to handle high level of concurrency
> for a long time now and hence it's not required to have a singlethreaded
> workqueue just to gain concurrency. Unlike a dedicated per-cpu workqueue
> created with create_singlethread_workqueue(), system_wq allows multiple
> work items to overlap executions even on the same CPU; however, a
> per-cpu workqueue doesn't have any CPU locality or global ordering
> guarantee unless the target CPU is explicitly specified and thus the
> increase of local concurrency shouldn't make any difference.

Not relevant.

>=20
> Work item has been flushed in mlx5_health_cleanup() to ensure that
> there are no pending tasks while disconnecting the driver.
>=20
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/health.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/n=
et/ethernet/mellanox/mlx5/core/health.c
> index 42d16b9..9acbccf 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
> @@ -267,7 +267,7 @@ static void poll_health(unsigned long data)
>  	if (in_fatal(dev) && !health->sick) {
>  		health->sick =3D true;
>  		print_health_info(dev);
> -		queue_work(health->wq, &health->work);
> +		schedule_work(&health->work);
>  	}
>  }
>=20
> @@ -296,7 +296,7 @@ void mlx5_health_cleanup(struct mlx5_core_dev *dev)
>  {
>  	struct mlx5_core_health *health =3D &dev->priv.health;
>=20
> -	destroy_workqueue(health->wq);
> +	flush_work(&health->work);
>  }
>=20
>  int mlx5_health_init(struct mlx5_core_dev *dev)
> @@ -311,10 +311,7 @@ int mlx5_health_init(struct mlx5_core_dev *dev)
>=20
>  	strcpy(name, "mlx5_health");
>  	strcat(name, dev_name(&dev->pdev->dev));
> -	health->wq =3D create_singlethread_workqueue(name);
>  	kfree(name);

You need to remove "name" initialization/usage too.
It is not needed.

> -	if (!health->wq)
> -		return -ENOMEM;
>=20
>  	INIT_WORK(&health->work, health_care);
>=20
> --
> 2.1.4
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXixP3AAoJEORje4g2clindz0QAI8K/f0/y+IVuC2TqpOr88pY
lZV8JX7S/Yyhfi9so6o6fYp11L3js/dNYCeEpwy74fGsMB8RCnvCCsZDjg6C3tUq
hc3lHBngDuXkLQMrNprolBKCZou8glO+zW6bzCNRjWEu6/h7t9Bx+HwDXv/qJ/WX
st2yZp6FIOKPWcZWTNGE8jIZC9PJJgykPWCby2aLH3q+Vlo/HdTFHj8NEenMLNFG
LtjiguPa4YnVIuKMs8+W1DAmDYhW8AnDX2mGpbGJamAfILo3M5KyroudVMRZkZYv
7ijUVzjJ7FXVQkuV+j/gyK/13x2t3EKA2GUg+/K5yklql+5Bro8elndMvI9GkKHs
A3e+S9cCvLf0dvkpr9fLRtdXfck0sUp3XHXHRk5Pxb5S1Z7DVSM+G7jKCEvg+I5g
Y0/yHs3XSPr+CM9afTHHAGV2K5BbxWxf8cFCZhL/RwcrmzoRGGW05Rgn4c3W96Y/
PuOVh1tCON2Gib/nPWD4jUHAHgd3EpkYn9maajnkAmQkY/kva5HMN+FxzAjJN+8g
4qCwWi1CLEB+BtK8yPryJZ2sxoKJHVTmoDtciASgTmdKojzBt5LhYo8Z5FQR/37X
IWc1C1r9Yb3Uv737krXfw0iXzNt3OGWg4R1zyMjwOkDpHxvEOd4BHXZRbSNFwSpR
Z12IM246y/U9atbDlyLS
=KofD
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
