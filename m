From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] net/mlx5_core/pagealloc: Remove deprecated
 create_singlethread_workqueue
Date: Thu, 28 Jul 2016 12:37:35 +0300
Message-ID: <20160728093735.GO4628@leon.nu>
References: <20160728081949.GA5561@Karyakshetra>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2IK6idz0sKKouFF6"
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160728081949.GA5561@Karyakshetra>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--2IK6idz0sKKouFF6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 28, 2016 at 01:49:49PM +0530, Bhaktipriya Shridhar wrote:
> A dedicated workqueue has been used since the work items are being used
> on a memory reclaim path. WQ_MEM_RECLAIM has been set to guarantee forward
> progress under memory pressure.
>=20
> The workqueue has a single work item. Hence, alloc_workqueue() is used
> instead of alloc_ordered_workqueue() since ordering is unnecessary when
> there's only one work item.
>=20
> Explicit concurrency limit is unnecessary here since there are only a
> fixed number of work items.
>=20
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Hi Bhaktipriya,

First of all, I would like to thank you for your work and invite you to
continue, but can you please submit ONE patch SERIES which changes all
similar places?

BTW,
Did you test this patch? Did you notice the memory reclaim path nature
of this work?

Thanks

>=20
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/driver=
s/net/ethernet/mellanox/mlx5/core/pagealloc.c
> index 9eeee05..7c85262 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> @@ -552,7 +552,8 @@ void mlx5_pagealloc_cleanup(struct mlx5_core_dev *dev)
>=20
>  int mlx5_pagealloc_start(struct mlx5_core_dev *dev)
>  {
> -	dev->priv.pg_wq =3D create_singlethread_workqueue("mlx5_page_allocator"=
);
> +	dev->priv.pg_wq =3D alloc_workqueue("mlx5_page_allocator",
> +					  WQ_MEM_RECLAIM, 0);
>  	if (!dev->priv.pg_wq)
>  		return -ENOMEM;
>=20
> --
> 2.1.4
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--2IK6idz0sKKouFF6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXmdJfAAoJEORje4g2clin/50QAJshtqgSuJRX73DiWueaQx4L
epaR3vBS/iP3qrsxWGdL/YEvje9o2K65F3bear8vIhHZtvSEtEb+2p96cmAmZnUE
yYyPuxuZiD1M6F6xfXFlJJ79RtnIhzsvrgDqyGBb5g6q9otBJojwddgwyQsuAwus
hT5aBzrkX0QNR0/nZdl6G9+AHSBpOR/qua0xiQQ3ksn2RSmN1hxip0HupWz/9LCB
Hch3FZzTAxtS+06NrZLIYNI7knyArhDd7NHCpG6ORC3z5op8GsXl3BIwlPZZhbNA
RIlFDKsXAh8kZonPxjNVe8WnflC4AKszP4XO6caa6xN97Ixp0X5Ejidc53MLxxFM
tMYUveXZQYTncudPCRnU1/DEmOiIlO4CTmg/+c40Ae/lQb5uaZwyFhpARJ74oB/0
65CQCdd9lQJHpnE/ImUH2xUmyrStpV9EpVwEp1Ra/1w5sgwup5Yon81oSFsu4YLq
MdIkxDbnKt2LkVVuAFoqsQVXclFPT62sCIWSQNLz7G7+MWC5zc1eAY987SRATsL6
u44mDna/ddmAoQjXhsQNXYc9Q8HXvb+Zf1w+k7vhIwKS2ptgYArnjV04hcicBt6R
Brl3v0RjI4ToKGIyfFDuWI/0g6VOaoShNxMEyt1f6PXwir3P89M7/tdN1lhkcutw
XQcvmvUMJq3VhTd4Aj/c
=AC9W
-----END PGP SIGNATURE-----

--2IK6idz0sKKouFF6--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
