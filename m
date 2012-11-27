From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: linux-next: manual merge of the net-next tree with the infiniband
 tree
Date: Tue, 27 Nov 2012 11:47:51 +1100
Message-ID: <20121127114751.6961da02245ed6851190aca2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__27_Nov_2012_11_47_51_+1100_Gy39B++J1yJCVRUm"
Cc: linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__27_Nov_2012_11_47_51_+1100_Gy39B++J1yJCVRUm
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/mellanox/mlx4/en_rx.c between commit 08ff32352d6f
("mlx4: 64-byte CQE/EQE support") from the infiniband tree and commit
f1d29a3fa68b ("mlx4_en: Remove remnants of LRO support") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

diff --cc drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6fa106f,f76c967..0000000
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@@ -710,12 -709,9 +710,9 @@@ next
 =20
  		++cq->mcq.cons_index;
  		index =3D (cq->mcq.cons_index) & ring->size_mask;
 -		cqe =3D &cq->buf[index];
 +		cqe =3D &cq->buf[(index << factor) + factor];
- 		if (++polled =3D=3D budget) {
- 			/* We are here because we reached the NAPI budget -
- 			 * flush only pending LRO sessions */
+ 		if (++polled =3D=3D budget)
  			goto out;
- 		}
  	}
 =20
  out:

--Signature=_Tue__27_Nov_2012_11_47_51_+1100_Gy39B++J1yJCVRUm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQtA23AAoJEECxmPOUX5FEJcMP/2uAYVgOIr10CkQFnoiWvveh
cExGTI7BMFm3VfzrZsXPH2vAGTzZoRwVyBnhQzobRHcjTplJkthAnNDq1xb7eDxt
4EMF+6wcnqlnKmG27osfE5Fnh4/mFXZdDxhgbyHuzc9aa1nXhVD1n/jW/tyLBgsn
OSQcTVAEkDVvAN6WohATaeyEQ+HkwWLYWdBtmMrPDdnjeH2GA3NgEuD904lJT2IU
Z93w73/ITIj+8f7MtpxeTGH1SDx8XtrUYk5sQ5vaADSIdcVCGeDj/AZrsg8ezk//
/I9AeqAHQUHY/Pu5MTO6aLPqFY7TkExjk89Fbm4fXuptA9u1Jp1a1DVXxrqnghjG
UEpX1+8yqTwZSJT6QbwgVddseBN9mdDrjE9SOLHR9VeEa92oTiWQA2Uaaw5DDres
dfTjozkpHL6BpOGmwx9fdmzGvZLwXfkwdvncyxUtouMft7gnNkFu61o5Y6AgXBSw
a0N8IXqIcX2sNtJ35mqVVb0K34MrjV/8EfN9V1D32KWdqUWkBi4iHEySvc49FWdy
XsQygg6VUIIqYIDuV0kLUXwc651wCbVF1GtjvDgAcWuKgjWZdcMFxLuv3co+kx+Y
7HTSbgKM82zeI2Cw0WRgnhuepKbPVN/MWfM2ujuwFf+el5P0PAUdARqKcvAbe/rC
wgzW2pkCenm+Ltk+H3D/
=E4sO
-----END PGP SIGNATURE-----

--Signature=_Tue__27_Nov_2012_11_47_51_+1100_Gy39B++J1yJCVRUm--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
