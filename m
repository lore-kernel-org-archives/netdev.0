From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHv3 1/4] rds: ib: drop unnecessary rdma_reject
Date: Mon, 13 Mar 2017 08:32:24 +0200
Message-ID: <20170313063224.GJ2079@mtr-leonro.local>
References: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
 <1489383828-7699-2-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="oXNgvKVxGWJ0RPMJ"
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
To: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489383828-7699-2-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--oXNgvKVxGWJ0RPMJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 13, 2017 at 01:43:45AM -0400, Zhu Yanjun wrote:
> When rdma_accept fails, rdma_reject is called in it. As such, it is
> not necessary to execute rdma_reject again.

It is not always correct, according to the code, rdma_accept can fail
and will return EINVAL and skip calling to rdma_reject.

3725 int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
3726 {
3727         struct rdma_id_private *id_priv;
3728         int ret;
3729
3730         id_priv = container_of(id, struct rdma_id_private, id);
3731
3732         id_priv->owner = task_pid_nr(current);
3733
3734         if (!cma_comp(id_priv, RDMA_CM_CONNECT))
3735                 return -EINVAL;
3736


>
> Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  net/rds/ib_cm.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
> index ce3775a..4b9405c 100644
> --- a/net/rds/ib_cm.c
> +++ b/net/rds/ib_cm.c
> @@ -677,9 +677,8 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
>  		event->param.conn.initiator_depth);
>
>  	/* rdma_accept() calls rdma_reject() internally if it fails */
> -	err = rdma_accept(cm_id, &conn_param);
> -	if (err)
> -		rds_ib_conn_error(conn, "rdma_accept failed (%d)\n", err);
> +	if (rdma_accept(cm_id, &conn_param))
> +		rds_ib_conn_error(conn, "rdma_accept failed\n");
>
>  out:
>  	if (conn)
> --
> 2.7.4
>

--oXNgvKVxGWJ0RPMJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljGPPgACgkQ5GN7iDZy
WKdTohAAvpqn7inFihU5qA9L+JFZs2R/piC5EuZEcLogrM3JobpBy5OH7RT7GDnC
0XxSmz3EoJs+DQGnLISZglGwCFaOXaFoFTGD0bLl1d7yq4rv0vkHFKarSzzaMmmZ
2VzLkoMG9nr1POC6+cfLqRglcSPKvdHOsbFiqLGl2jQc9N8IG270nRuOUyCo0MHq
4dbvRG54C2DmS6rlIUtgUVadpBJuiw2obTyufp4hq1/bpRwl8TvUB3cXdfnff+OD
5H05LJQleZjDcBKcZQaa/O4LO2vkric7oUss+Z5kj3ESIYX7T7ZGqRSWA0QGzAIE
rJuVWdNrfQklGU7O3Hx21okanFgOAeoW+PMJymuLG03dJqxwOEVGLy61OrAclYAo
FGZgyXKm3Uc4tXcIgKy3vyRw2JJ8oLugMoHiq+mFHgjy+USpdsaze/0ng4iphGHC
QuLovFrsu/EJsWAcTtI0UO6P5HSaRUvSA7rLZ0+EopuvRlkRL/FnUBctNiNIXLRX
0quqQBxf3Oz35M/YEx1khsw3iVWsM4yJnkjTIgCD4C0BhomUcEdreYl+mbB2qbG6
x2B4bhwYP+QRyInN8bs3EwodIg/1ehIiE2V0V91NWlNZzUgKVWrf9/FKjZGo9bbu
UDc3EVCP5IyMp5PRmDlPaXTlm752HtTWgP700kAzCL03fteLchQ=
=uBjS
-----END PGP SIGNATURE-----

--oXNgvKVxGWJ0RPMJ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
