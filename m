From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] net/mlx4: use rb_entry()
Date: Sun, 22 Jan 2017 09:48:39 +0200
Message-ID: <20170122074839.GD28570@mtr-leonro.local>
References: <c6a809ea5820242a4ae126b03cdcd910a36e5cae.1484817152.git.geliangtang@gmail.com>
 <6c1c772de8f70113580dade04f89a377174d8c88.1484817025.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="uxuisgdDHaNETlh8"
Cc: Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:57748 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750912AbdAVHsl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Jan 2017 02:48:41 -0500
Content-Disposition: inline
In-Reply-To: <6c1c772de8f70113580dade04f89a377174d8c88.1484817025.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uxuisgdDHaNETlh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 20, 2017 at 10:36:57PM +0800, Geliang Tang wrote:
> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
>
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

I don't understand completely the rationale behind this conversion.
rb_entry == container_of, why do we need another name for it?

>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> index 1822382..6da6e01 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> @@ -236,8 +236,8 @@ static void *res_tracker_lookup(struct rb_root *root, u64 res_id)
>  	struct rb_node *node = root->rb_node;
>
>  	while (node) {
> -		struct res_common *res = container_of(node, struct res_common,
> -						      node);
> +		struct res_common *res = rb_entry(node, struct res_common,
> +						  node);
>
>  		if (res_id < res->res_id)
>  			node = node->rb_left;
> @@ -255,8 +255,8 @@ static int res_tracker_insert(struct rb_root *root, struct res_common *res)
>
>  	/* Figure out where to put new node */
>  	while (*new) {
> -		struct res_common *this = container_of(*new, struct res_common,
> -						       node);
> +		struct res_common *this = rb_entry(*new, struct res_common,
> +						   node);
>
>  		parent = *new;
>  		if (res->res_id < this->res_id)
> --
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--uxuisgdDHaNETlh8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliEY9cACgkQ5GN7iDZy
WKeDTw/+J9x8ygvxpRu+slKFFqZXXPARllOV3nH6hmGHi/QkAeQcvTj0R6/p1AjS
4viEM5OC3ai6XOWrgt2dniJU2v3pUMHwH6+U1zi3IkFgvb0wFzZhv1mOnj5Xsu0I
IUT9380PZip2ChFpP/S7FUIN5zsm8VejU9dlhkgW+TFlbdEo4djr4+brdXBcLigP
kAalbPOiNkOmwJEnZPq3AQPtrkyM3ASkhUON1iOEdxpr0SzXt5H7A0qMRJWubOVR
tqZEsQQKYdRMLW+Am22L3Bi9D0vQgMvOEbClVtZKQXTkiUazLZcx6Qv87CZBoJY2
tXXTX1evRSXqTomcPt3kmRUM9tyec91EpJpqj+F9ZvHU+cJMk0acePPTY+QqmMQd
kDNNkT7f0LZSsy4DcgzMaDuYl3LfrIknPcJmSnHiOpdvmE+KlVQb1ys9R7sKUBd6
n+5YSdyhlxzrWAZKjC3TITj72os9xCP8nkSyP18kb5aq15wL2mjB7BDOWT9nUz1W
/VvfG7WQReG4PUG+wPuVu2AbgWeFq0o7th9eZXSAVT4OAeN52IP7Ywd0djTgj4w6
XBQVifFsovqHJFrI+CaDdhplpDj85IHRv67SUq8AkWjv75dEE4TJo2u9WqXKvk/8
mcU+tiZr+DLdZDY5t8J0AgudxECB7mPk4jUzlbCIBhsUi7KYHxM=
=PYQU
-----END PGP SIGNATURE-----

--uxuisgdDHaNETlh8--
