From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] RDS: use rb_entry()
Date: Tue, 20 Dec 2016 16:20:33 +0200
Message-ID: <20161220142033.GY1074@mtr-leonro.local>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
 <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="YZa61AII3s1sGKYx"
Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YZa61AII3s1sGKYx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 20, 2016 at 10:02:18PM +0800, Geliang Tang wrote:
> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
>
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  net/rds/rdma.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

>
> diff --git a/net/rds/rdma.c b/net/rds/rdma.c
> index 4c93bad..ea96114 100644
> --- a/net/rds/rdma.c
> +++ b/net/rds/rdma.c
> @@ -135,7 +135,7 @@ void rds_rdma_drop_keys(struct rds_sock *rs)
>  	/* Release any MRs associated with this socket */
>  	spin_lock_irqsave(&rs->rs_rdma_lock, flags);
>  	while ((node = rb_first(&rs->rs_rdma_keys))) {
> -		mr = container_of(node, struct rds_mr, r_rb_node);
> +		mr = rb_entry(node, struct rds_mr, r_rb_node);
>  		if (mr->r_trans == rs->rs_transport)
>  			mr->r_invalidate = 0;
>  		rb_erase(&mr->r_rb_node, &rs->rs_rdma_keys);
> --
> 2.9.3
>

--YZa61AII3s1sGKYx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhZPjEACgkQ5GN7iDZy
WKenhxAAwM9W5FEYsSEq07R/eQrw1VY7jJye6FvJtdpTslMGdamFNal40mFBk87P
JkyqzbtlrrEakVEObt8a3UgmWvLlW9V+xv9kDAfClqtmgTFVfnCws0mDlVqOc6K5
l7UiR4Z6SQYy7VmVPL2VLZ2jR+e1wzc9+XWRihTw/cclqqZCivKHaMjLPbm8QOZe
MUQ+P9RdSbweFtniWgWA8KHIOLMKF6UUwRS4Jsu+P/Wa3YMMv6EUYfw8vRzaIPnO
4xLsrrwNAOWuZwRYomTeM/NEFRUWFafsHJtPhaPxOlaYvXgVt2LVq74AI/VibEuD
ITWLPFRy3rkLM9uFT/B06EZORz5GiC+QGw+NfmctEjxzd65mJCGMSXq0xfzh0Caj
IDVoKilDZYeW/kbri5VDF6Ziomm2P97wQBI8B3/y0s55+HSfZ/+leOEcAmWBtIoj
ypYN4aS9FRiJTBHwqRl4467rbGrMxe0h6jHZdy8STTGxVFtc4+g/4GOANum9v7fm
lJ+SqoeUlLjlssRczDf88LdzalwMD12wdd0SL1SycOBKo0pyEHKBOOoL9fHcTVkq
ZvpZuDDlkKRFRYp+rwt/hQsUBEakR1262oJrmaqFlvq+HBdjwAefo3LXJl6F01r2
iLhFfCyCmByU/ZFnUbA91OntT7NTBx6ESpdNf5tp2lTy6DAjRAU=
=lpu8
-----END PGP SIGNATURE-----

--YZa61AII3s1sGKYx--
