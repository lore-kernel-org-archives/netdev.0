From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net] net/mlx4: Avoid wrong virtual mappings
Date: Wed, 27 Apr 2016 09:32:54 +0300
Message-ID: <20160427063254.GM7974@leon.nu>
References: <1461591287-11595-1-git-send-email-hagaya@mellanox.com>
Reply-To: leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pFpMklMRdxwSC3Yi"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Abramovsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1461591287-11595-1-git-send-email-hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--pFpMklMRdxwSC3Yi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 25, 2016 at 04:34:47PM +0300, Haggai Abramovsky wrote:
> -int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
> -		   struct mlx4_buf *buf, gfp_t gfp)
> +static int mlx4_buf_direct_alloc(struct mlx4_dev *dev, int size,
> +				 struct mlx4_buf *buf, gfp_t gfp)
>  {
> -	dma_addr_t t;
> +		dma_addr_t t;
> =20

You have wrong indentation in whole this function.

> -	if (size <=3D max_direct) {
>  		buf->nbufs        =3D 1;
>  		buf->npages       =3D 1;
>  		buf->page_shift   =3D get_order(size) + PAGE_SHIFT;
> -		buf->direct.buf   =3D dma_alloc_coherent(&dev->persist->pdev->dev,
> -						       size, &t, gfp);
> +		buf->direct.buf   =3D
> +			dma_zalloc_coherent(&dev->persist->pdev->dev,
> +					    size, &t, gfp);
>  		if (!buf->direct.buf)
>  			return -ENOMEM;

--pFpMklMRdxwSC3Yi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXIF0WAAoJEORje4g2clin+okP/1wyIFHDr4yRXXUkKtWFQL3u
JPxORFJy4cSGUKusMRfhraqqNGgqB3Nv5zepQ00NLp0JCXGkR5slfGbYaYSrphzV
KcVBkk3XNN1MJdc72hTV214yWRpAZrXa8FZMn2XDUYTmVOn4f+yDGnyYros4dJQH
ObPLOK/7bwo2YbYVqi5obDB8A8apj6DkOvPnriE+1f19XmXlwV7QjaPli+hojaS+
aB802g/slusX+o52Mbn4DWYXQrUoHEme0ev1vd+UBfhNTWtHZAXS+MipWEfWbtKY
JhKuni5O2+f/Ew2T+ANML6xuvFrSdwGOdyBy4Y16CrqkB/LlVSGY6WphW0TorPSF
0Fn2k017ARu9QmDD53Fda1FeWAC/+xq7IR5sm8TZFObMH59+tQT/3Te2nRWf/Ztz
F5b7MngmzrTSwwv9LUg7QLUmqtEcR/CBQYbKnDK7PykhVVNY9qj5O0Q/mF198r3R
a4Ps4NpRLyDKYcp+01txjSI3Iha3PsfxG1UzpRlrEkA5/Cywjz29m/RM6vSkCtfX
SBfVjvXIOnF3gOzrXVSkrFP+rd6GVpZx5y64lzTRz/993C2IB3NSBAOCECvrYLvz
WVB0GJsjkbfWj5fZKgtLyZij/2y+XHpamFu+1ac35vCIzzFnvVYDAHaPQY16ehrN
M4wsURk2w9kHQcdeAsq9
=5EPD
-----END PGP SIGNATURE-----

--pFpMklMRdxwSC3Yi--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
