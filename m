From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4] net/mlx4_core: Use min3 to select number of MSI-X
 vectors
Date: Mon, 15 May 2017 07:43:04 +0300
Message-ID: <20170515044304.GV3616@mtr-leonro.local>
References: <1494569451-2567-1-git-send-email-yuval.shaia@oracle.com>
 <20170514190133.GC28994@yuval-lap>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="r3KnbM2MoJFBL7Dl"
Cc: <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170514190133.GC28994@yuval-lap>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--r3KnbM2MoJFBL7Dl
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, May 14, 2017 at 10:01:34PM +0300, Yuval Shaia wrote:
> On Fri, May 12, 2017 at 09:10:51AM +0300, Yuval Shaia wrote:
> > Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > ---
> > v0 -> v1:
> > 	* s/"min_t("/"min_t(int"
> > v1 -> v2:
> > 	* Use min3 instead of min_t twice
> > v2 -> v3:
> > 	* Change commit log header message to reflect the changes made in
> > 	  v2
> > v3 -> v4:
> > 	* Cast return value from num_online_cpus to int to avoid
> > 	  compilation errors from "sparse"
>
> Hi Leon,
> Got your r-b for v3, can you please review v4?

What was the sparse error?

num_online_cpus() is declared as "unsigned int", so you don't need to do ca=
sting.

=E2=9E=9C  linux-rdma git:(master) git grep num_online_cpus include/
include/linux/cpumask.h:#define num_online_cpus()       cpumask_weight(cpu_=
online_mask)
include/linux/cpumask.h:#define num_online_cpus()       1U

=E2=9E=9C  linux-rdma git:(master) git grep cpumask_weight include/
include/linux/cpumask.h:static inline unsigned int cpumask_weight(const str=
uct cpumask *srcp)

Thanks

>
> Thanks,
>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/main.c | 10 ++++------
> >  1 file changed, 4 insertions(+), 6 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/et=
hernet/mellanox/mlx4/main.c
> > index 7032054..83aab1e 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> > @@ -2862,12 +2862,10 @@ static void mlx4_enable_msi_x(struct mlx4_dev *=
dev)
> >  	int port =3D 0;
> >
> >  	if (msi_x) {
> > -		int nreq =3D dev->caps.num_ports * num_online_cpus() + 1;
> > -
> > -		nreq =3D min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
> > -			     nreq);
> > -		if (nreq > MAX_MSIX)
> > -			nreq =3D MAX_MSIX;
> > +		int nreq =3D min3(dev->caps.num_ports *
> > +				(int)num_online_cpus() + 1,
> > +				dev->caps.num_eqs - dev->caps.reserved_eqs,
> > +				MAX_MSIX);
> >
> >  		entries =3D kcalloc(nreq, sizeof *entries, GFP_KERNEL);
> >  		if (!entries)
> > --
> > 2.7.4
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--r3KnbM2MoJFBL7Dl
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkZMdcACgkQ5GN7iDZy
WKdIvRAAgX8qTKURg43eVjLLl3XWHDAc5epZp73nXs4xzxT+aRvugWtC67/O+0RT
Bbl5DoWNFcDP9uJ4gQmrXJMx0b5j/qI7/Iy4lhSL9OXVgn+qO3jkiDzfjv/d40UG
DBp8I03FglY1wIrqYXssPs7I731isbBliiXGNSUN/CmCq5knrFOA24YnpeRLsU4b
G1jVLgmBapptyoNy9A+zKUdcfhlHyTpJ2+z1V8ghJUnEGB1ncKnJbCbx9nYlAK5x
HZlukHWFYjjcXPR6Kj/VDU4F7wPi1MvZMQxUgkg3QT9DtbGtYE9PmbNKvOIAtXVw
CMVIArpoE0UhNuFAV2m7BtYNhHXyMM+B5K4TbgxdhUdz2OqZnqJFMRNSqIM3/+8L
fg8vLwmKDYm8Rqh6KcLrTkx9H4I0dD45ZACNUpW9GODiFeMsQyuQawsmNa48H+yR
srpvJyqQKvtBwYcTDF0g71QrlLxYGJO+Ei1s7S/ExLhnUxDjp6MtkhzSc9Zt1Z4H
GIATannr8gbWWBhK6q7tYR0ic+tt/CYogSUs7ho8GCzh6uMQZbj4Iifk2q/oYwsh
OmGC9OXIVlgFBMM8qchpf0tKRSPhF20qbe7fWdZmOGveSJBTPXvKWGPndhrGVu70
hM7fdskOwhDCAE8QhdvBKG7JoFpQ74FG3RMnaEau9AHWwCh7sSY=
=4Ndq
-----END PGP SIGNATURE-----

--r3KnbM2MoJFBL7Dl--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
