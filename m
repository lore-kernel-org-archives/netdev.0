From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] use smp_load_acquire()/smp_store_release()
Date: Wed, 29 Oct 2014 12:27:48 -0700
Message-ID: <1414610868.2420.52.camel@jtkirshe-mobl>
References: <1414594159.631.85.camel@edumazet-glaptop2.roam.corp.google.com>
	 <545112E0.40106@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qVrWG7NOqBYOlTc5MWUZ"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52919 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756280AbaJ2T1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2014 15:27:50 -0400
In-Reply-To: <545112E0.40106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qVrWG7NOqBYOlTc5MWUZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-29 at 09:16 -0700, Alexander Duyck wrote:
> On 10/29/2014 07:49 AM, Eric Dumazet wrote:
> > Hi Alexander
> >
> > The memory barriers added in commit
> > b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
> > ("net: Add memory barriers to prevent possible race in byte queue
> > limits")
> >
> > have heavy cost.
> >
> > It seems we could use smp_load_acquire() and smp_store_release()
> > instead ?
> >
> > I'll post a patch later today. I would be interested if someone was abl=
e
> > to test it, as your commit apparently was tested and known to fix a
> > reproducible race.
> >
> > Thanks !

Eric- just CC me on the patch you post and I will see what I can do
about getting validation eyes on it.

>=20
> Unfortunately Stephen left Intel before I did, so we will need to find=
=20
> someone else in the validation team to test this if possible. I have=20
> added Jeff to the CC so that he can give the appropriate validation=20
> people a heads up that this patch might be coming.
>=20
> As I recall what was seen was random Tx hangs on systems with the=20
> original BQL code when interfaces were stressed.  It has been a while so=
=20
> I don't recall the exact set-up for all of it.  Also some less=20
> used/tested architectures such as PowerPC can be more susceptible to=20
> synchronization issues such as these as the memory model is more weakly=
=20
> ordered.
>=20
> I'm wondering where you are seeing the barrier show up?  In=20
> netdev_tx_send_queue you should only hit the barrier if you actually are=
=20
> triggering the XOFF condition, and in netdev_tx_completed_queue the=20
> barrier should be coalesced in amongst a number of frames reducing the co=
st.
>=20
> My concern with this would be that we are actually syncronizing multiple=
=20
> things, the __QUEUE_STATE_STACK_XOFF flag, dql->adj_limit, and=20
> dql->num_queued, and we might be trading off reducing the cost on x86 to=
=20
> result in it being increased on other architectures as we may have to=20
> actually add additional synchronization as I suspect we would need to=20
> use acquire/release on both adj_limit and num_queued.
>=20
> Thanks,
>=20
> Alex
>=20



--=-qVrWG7NOqBYOlTc5MWUZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUUT+0AAoJEOVv75VaS+3Of8oP+wZxeBQWWuVeSRuQxYt8Z5bs
drtakhnpegK8m77JTAYVq+xllUqwHtWkFAhWuyLkjEao+hxJK7jtLIB+kJDcnPS6
lXTRRaOvhsvzG3A/kYpGDHySQXuYiexFuHHL/D9ySziNy0+Zo/hd0kS2vwYqnR5K
9KQsFX5i2o5lBQlWWXxyrdAH1zpVxXWB9U3tUpfA4sIwqGIwkB/BJjvExIk2g9W6
u9svAm/f/H/2dkpCvO3bRfxRPJWgiP9i5RMW8ZIKKKw5glLxKOmBGiQYhrN2i05t
EuFD1LNffVRI6LmuhS9DXQIBLpunuAZq+oUgXEb3WPWv7reIgoU9kGIsYCiMyGom
ZAmmKHHTXOWqz0zd5PwUy+pMI3r8mIhk6LwS84tzrkMLJE0UUl/fp7oPZ3G9/o3S
/xdaml/jZ4xEYDo0fLpo1cgMzPzC5TJJ/iUrWxsVhaG4FoJF0Ex54usj3UDUr8IN
wmDc5KPnkn3/998q8A+U9JMKI2+1E2LZasEXNWv0qRQ+zro+HUhRBSJRIDJLx8Wj
OBMvBdk27Lhl2iEGGDu9YDO9Ul8sH/TDOMJeN8oLov4VV0BWZdpkKBzjfevaLpAJ
IVlIx52zwNR5BTcOizm3eocdTNuBRF/Gq/WuYXLBOaJ446dwOrQ7iwH05fYqTWD1
+TEkUxQhcqeRz743QM4x
=Cg3K
-----END PGP SIGNATURE-----

--=-qVrWG7NOqBYOlTc5MWUZ--
