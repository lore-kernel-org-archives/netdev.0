From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 1/1] Fixed to BUG_ON to WARN_ON def
Date: Mon, 12 Dec 2016 14:39:37 +0200
Message-ID: <20161212123937.GA6503@mtr-leonro.local>
References: <811031481540339@web1j.yandex.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="envbJBWh7q8WU6mo"
Cc: yishaih@mellanox.com, netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Ozgur Karatas <okaratas@member.fsf.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <811031481540339@web1j.yandex.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Dec 12, 2016 at 12:58:59PM +0200, Ozgur Karatas wrote:
> Hello all,
> I think should be use to "WARN_ON" and checkpatch script give to error, I fixed and I think  should don't use "BUG_ON".
> Regards,
>
> Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>

NAK, Leon Romanovsky <leonro@mellanox.com>

If we put aside commit message issue, which was pointed to you by Stefan, your
proposed change is incorrect. By chnaging BUG_ONs to be WARN_ONs, you
will left the driver in improper state.

Thanks

> ---
> drivers/net/ethernet/mellanox/mlx4/icm.c |  4 ++--
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
> index 2a9dd46..3fde535 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/icm.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
> @@ -119,7 +119,7 @@ static int mlx4_alloc_icm_coherent(struct device *dev, struct scatterlist *mem,
>  		return -ENOMEM;
>
>  	sg_set_buf(mem, buf, PAGE_SIZE << order);
> -	BUG_ON(mem->offset);
> +	WARN_ON(mem->offset);
>  	sg_dma_len(mem) = PAGE_SIZE << order;
>  	return 0;
>  }
> @@ -133,7 +133,7 @@ struct mlx4_icm *mlx4_alloc_icm(struct mlx4_dev *dev, int npages,
>  	int ret;
>
>  	/* We use sg_set_buf for coherent allocs, which assumes low memory */
> -	BUG_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
> +	WARN_ON(coherent && (gfp_mask & __GFP_HIGHMEM));
>
>  	icm = kmalloc_node(sizeof(*icm),
>  			   gfp_mask & ~(__GFP_HIGHMEM | __GFP_NOWARN),
> --
> 2.1.4

--envbJBWh7q8WU6mo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhOmn4ACgkQ5GN7iDZy
WKcCqg//f79xAdUNvX6xucb9X0m/rNvRc7edKzGAK+WYTNUOMKrd6Bg43NhHoLMe
gLk+mnyzFJd4LauTPmkluneKaQ4hoyTOSjMUmWeWsnkcvLmnGCNB4KLMhrOWrySg
ysixOqfZPr73giWIvYs5sU/jWKii6V+47BGkIyPvXz1R609zA/XrJ1Ip+LTs9LfZ
QfzSKiHM0yNKmU0DIwcjiwbvWXCHMzIxDL8Vs+3RXhqnOMm0sYkbcGQphLtpvUCz
fOuVJPWnD4YkeCgWeXxd7moGVvM1z6boneaSqMrTig9xTT/wlkX9/lWkZzQRHoxV
sei2fqFzz3PSA/A8XG5nfvuIoYKTz0YyD9B/VkeaS/OGGD1Z9Q00CvnqgbzQY2yZ
pR1viV5VfaYH3FA7L9ArHCNYj4g8W4mgt1TxIDp1dt9KwKor7tbkSMAgSeLE5olx
PO2P3A6NG+rP9zTF2Pt3sYu5iHSACg0m3dJMEPPr+rAfC6mw9On/4hWR4cNR82eL
vm0XbkR9Zfc0YBLUf2Rd489tJBbYv9+szLDvbFRfSl/ccsCI2jjn4pQio5tWDWUd
Dye3u5jM72/9EmO0HInrKV0zXjXhDsD3GboBu2t1nZZqqk3yTVZazEKoqQYgkW53
WoqT8iB7CsGk7G/rbXHiniZyuH00qjjEtP1i+KrDn8RH8VTt314=
=4XEQ
-----END PGP SIGNATURE-----

--envbJBWh7q8WU6mo--
