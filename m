From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] RDS: Simplify code
Date: Sun, 4 Sep 2016 15:20:49 +0300
Message-ID: <20160904122049.GQ21847@leon.nu>
References: <1472880809-29216-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="psiTe9LjpVyD9953"
Cc: santosh.shilimkar@oracle.com, davem@davemloft.net,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472880809-29216-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--psiTe9LjpVyD9953
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Sep 03, 2016 at 07:33:29AM +0200, Christophe JAILLET wrote:
> Calling 'list_splice' followed by 'INIT_LIST_HEAD' is equivalent to
> 'list_splice_init'.

It is not 100% accurate

list_splice(y, z)
INIT_LIST_HEAD(y)

==>

if (!list_empty(y))
     __list_splice(y, z, z>next);
INIT_LIST_HEAD(y)

and not

if (!list_empty(y)) {
     __list_splice(y, z, z>next);
     INIT_LIST_HEAD(y)
}

as list_splice_init will do.


>
> This has been spotted with the following coccinelle script:
> /////
> @@
> expression y,z;
> @@
>
> -   list_splice(y,z);
> -   INIT_LIST_HEAD(y);
> +   list_splice_init(y,z);
>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
>  net/rds/loop.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/rds/loop.c b/net/rds/loop.c
> index f2bf78de5688..c3e6da4fdf97 100644
> --- a/net/rds/loop.c
> +++ b/net/rds/loop.c
> @@ -167,8 +167,7 @@ void rds_loop_exit(void)
>
>  	/* avoid calling conn_destroy with irqs off */
>  	spin_lock_irq(&loop_conns_lock);
> -	list_splice(&loop_conns, &tmp_list);
> -	INIT_LIST_HEAD(&loop_conns);
> +	list_splice_init(&loop_conns, &tmp_list);
>  	spin_unlock_irq(&loop_conns_lock);
>
>  	list_for_each_entry_safe(lc, _lc, &tmp_list, loop_node) {
> --
> 2.7.4
>

--psiTe9LjpVyD9953
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXzBGhAAoJEORje4g2clinrBcP/0pGSB+6M+EEupGEnHjxbeYW
ygKiZBvFo6EH609fNsYdHUNlgueLN6m548guP7uZmbpiwzye/NNWZBZmtrrI5FI+
H4qdJ/c/y0UI8VyNwUFYXYdGrxvBkH8gvFgLxnsTuRXh/5E5c5wEzfURne4YTtqO
rM5BBd4MnhNcJFXnt0PwXHoDP9w4+V1xGMy3P95UDef74aCOjkbGScmzKrx7g3BP
WZhV4fGMrvB9p5t1jmduE3quyAcv8FUm9ieVL4u7n/OwIIbftPFYgyDQ9MUA7izc
pMX+MvuZZxetdhKnqZxTb4OvB2nDK8gHgwBDyF2p5kUW5GGVwDezgbjCJZjsAxzz
bnQ/HVDehfYGCdYSp/t+xTRuAXx73phHaJvbANkSSiCl5B2UIeptkCs9mt96Rbc2
7/adcYVyE2XGlkDcFVAvfHDrX4V5TIR9FOxpsMYJPR9HIyYcMQrQdodyxhDNE+/c
6W8SFdTv657V/aBw0ldESmn/l9FHSrnKuN6NB//1wwW8RclaWP4LNTSknEjEYHvL
61pW9JhN0XtWV92INHvs3VIap6ZwcMnv9+juhJVSz403f0hv6FhmiGYMAvR5dmpi
zNOyWlV3PZ72OHZR5fq9OpjDf3LCtX8Aw4kFwkYC05aMoi5j7NQHlWlmxFJyQ0HP
Qw7EeA9sayw+22izXlWT
=XtxE
-----END PGP SIGNATURE-----

--psiTe9LjpVyD9953--
