From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] RDS: Simplify code
Date: Sun, 4 Sep 2016 21:23:54 +0300
Message-ID: <20160904182354.GR21847@leon.nu>
References: <1472880809-29216-1-git-send-email-christophe.jaillet@wanadoo.fr>
 <20160904122049.GQ21847@leon.nu>
 <befa1a39-cfc5-721f-e39a-369436237b1c@wanadoo.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="CMEQapY8OuP5ao1l"
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <befa1a39-cfc5-721f-e39a-369436237b1c-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--CMEQapY8OuP5ao1l
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 04, 2016 at 05:57:20PM +0200, Christophe JAILLET wrote:
> Le 04/09/2016 =E0 14:20, Leon Romanovsky a =E9crit :
> >On Sat, Sep 03, 2016 at 07:33:29AM +0200, Christophe JAILLET wrote:
> >>Calling 'list_splice' followed by 'INIT_LIST_HEAD' is equivalent to
> >>'list_splice_init'.
> >It is not 100% accurate
> >
> >list_splice(y, z)
> >INIT_LIST_HEAD(y)
> >
> >=3D=3D>
> >
> >if (!list_empty(y))
> >      __list_splice(y, z, z>next);
> >INIT_LIST_HEAD(y)
> >
> >and not
> >
> >if (!list_empty(y)) {
> >      __list_splice(y, z, z>next);
> >      INIT_LIST_HEAD(y)
> >}
> >
> >as list_splice_init will do.
> >
> You are right but if you dig further you will see that calling
> INIT_LIST_HEAD on an empty list is a no-op (AFAIK).
> And if this list was not already correctly initialized, then you would ha=
ve
> some other troubles.

Thank you for the suggestion,
It looks like the code after that can be skipped in case of loop_conns
list is empty, the tmp_list will be empty too.

174         list_for_each_entry_safe(lc, _lc, &tmp_list, loop_node) {
175                 WARN_ON(lc->conn->c_passive);
176                 rds_conn_destroy(lc->conn);
177         }

>
> CJ
>

--CMEQapY8OuP5ao1l
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXzGa6AAoJEORje4g2clinDLgP/RSZo5pW3kjwnEP/0ZjhBNeN
F7QBLZjepfUAtZs1auil1qjTfxRTY1B4+fJTdxaaQbIAdT8ESc6eBfY0YH7Mc3fz
PbuU8nZ1vFBiG0x2Emc5TgF+WqAX1Wsdgz+kYs63fG2BhWio0wQPqesnJq28G7qZ
ro82SyMbcypvUMHV3y3LwEGpoQc/SWhLBze0SKnzDw68oTbEnZqdLH83JSsWYSof
fs1EEuXcpunkX26i4U9YK8ynVCZvt79+h1JD5na4Xa8DKz/NenT2kYcY0XPk2KGc
o6qqnL/Fd3HpmyYtN44j3l56Narb3UC5FmmjHXx7ZXw2jVXhjzvulbXqH+2wPxXa
3STcAH+hNVYCsVvBmc1L+mcPi0XH/rSjAhMUmtxkapur6KVWFtumkFoWevAyhkda
66xuIFvuEFBvi+UncxTs/SIRuTz8f9PYAu2/du5Oxo9oHlx+uA7hww3Aq9Dy8+TC
EEDPcJ5wy/H8QZXVRsLpDQ8PI3iO7T+01srnyKeo4GItkGnF5jDO2qZsV1VsPhqK
kV/icRXKwHsR7LwjJMu6/PVTd3KiEriW2nUydbRRH0suM7npw+mZz4OcTvLpzNU+
yI6nkZ86fFlGWyTsflibpbKcBBn5meNCHwVvseVrmjAKv5mYD80wo6gfI+/Zo5fM
juDrdCTxlgj+bILm4+ct
=esBF
-----END PGP SIGNATURE-----

--CMEQapY8OuP5ao1l--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
