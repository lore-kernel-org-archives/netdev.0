From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 net] ixgbevf: fix invalid uses of napi_hash_del()
Date: Sat, 03 Dec 2016 08:46:12 -0800
Message-ID: <1480783572.2410.11.camel@intel.com>
References: <1479309315.8455.189.camel@edumazet-glaptop3.roam.corp.google.com>
         <1479310010.8455.197.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480777216.18162.404.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-imYfl+p0VqxX/vFko+SC"
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:30062 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751266AbcLCQqO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 11:46:14 -0500
In-Reply-To: <1480777216.18162.404.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-imYfl+p0VqxX/vFko+SC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2016-12-03 at 07:00 -0800, Eric Dumazet wrote:
> On Wed, 2016-11-16 at 07:26 -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > Calling napi_hash_del() before netif_napi_del() is dangerous
> > if a synchronize_rcu() is not enforced before NAPI struct freeing.
> >=20
> > Lets leave this detail to core networking stack to get it right.
> >=20
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> > =C2=A0 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |=C2=A0=C2=A0=
=C2=A0 6 ------
> > =C2=A0 1 file changed, 6 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > index 7eaac3234049..bf4d7efc7dbd 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > @@ -2511,9 +2511,6 @@ static int ixgbevf_alloc_q_vectors(struct
> > ixgbevf_adapter *adapter)
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0while (q_idx) {
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0q_idx--;
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0q_vector =3D adapter->q_vector[q_idx];
> > -#ifdef CONFIG_NET_RX_BUSY_POLL
> > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0napi_hash_del(&q_vector->napi);
> > -#endif
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0netif_napi_del(&q_vector->napi);
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0kfree(q_vector);
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0adapter->q_vector[q_idx] =3D NULL;
> > @@ -2537,9 +2534,6 @@ static void ixgbevf_free_q_vectors(struct
> > ixgbevf_adapter *adapter)
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0struct ixgbevf_q_vector *q_vector =3D adapter-
> > >q_vector[q_idx];
> > =C2=A0=C2=A0
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0adapter->q_vector[q_idx] =3D NULL;
> > -#ifdef CONFIG_NET_RX_BUSY_POLL
> > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0napi_hash_del(&q_vector->napi);
> > -#endif
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0netif_napi_del(&q_vector->napi);
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0kfree(q_vector);
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> >=20
> >=20
>=20
> It looks this patch was not picked up ?

Yeah, sorry I missed it since it was not sent to intel-wired-lan mailing
list.  Dave I am fine if you want to pick this up for your net tree (if it
is not too late).
--=-imYfl+p0VqxX/vFko+SC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYQvbUAAoJEOVv75VaS+3OQk4P/2zKfq3e0Cc9W58kZD2Ew+45
XlSGsGRqtTBpySUstRpFh9rrfdt6LBnlmKDISwGySn03hXu0jUlBevUCTDpYldDc
dugg3jhB18HOLv7W5HudXyPh0ZO2zHMVvmERxYtwa6tUF6CtlWrhD1LJ1MAoT+AJ
xhJFzmGcAWQYKl0/shV1XoZvOKJWxvu8LCa+9pzffFGvuv2sq1WZWXg//gkySeru
3PZefDpwXxVFSB9vS5TlyQCqEC3luUODmjUihNToyT4KI4evxDNLtJGDTIDZIWub
rlo2p8ee2HWryH7X97WMAx+3AbaZw5IU9xPtyI6/HhMh/Z+yH1EAAiglMvAXSH4G
q1Ei9iw2Nm3vDa+xZ+xi9EZvmWkOE6sjbE3xc8r03shxVXLELmmBJvyjaQdu1Ai5
wY987oSpJPZ1X1W7HqfeOvPXPhqLIcsvGIytixotQ61hMctBsB8GJFPFvPyYdRMq
YhrYM9SiRsQwP7K4wU8Ju2J/mqkYwhzaLRbLdVY8fok0dBMUM31Duab2WdtQHvPD
2QCHK2Q+UJTDEbKJfQtbY9kE8GdFtKLyBadzrtO4YtLpOqg1dRd+h97PPlFY4WxV
Hj7C+kRKDjNiJPP+rfKP9dQjiWQMaMPPHAhSJLrOZORUgNKXCHiYmKKHM9Rw/m63
pkfWjX+yXg7A5cykbB7A
=107y
-----END PGP SIGNATURE-----

--=-imYfl+p0VqxX/vFko+SC--
