From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ethernet: e1000e: define lat_ns as u64 instead of s64
Date: Wed, 08 Apr 2015 11:13:02 -0700
Message-ID: <1428516782.2579.2.camel@jtkirshe-mobl>
References: <1428052673-16412-1-git-send-email-yanjiang.jin@windriver.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB166B0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4dLaWvVnUg81OubZRAc+"
Cc: "'yanjiang.jin@windriver.com'" <yanjiang.jin@windriver.com>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jinyanjiang@gmail.com" <jinyanjiang@gmail.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51133 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932136AbbDHSNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 14:13:04 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB166B0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4dLaWvVnUg81OubZRAc+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 09:40 +0000, David Laight wrote:
> From: yanjiang.jin@windriver.com
> > Sent: 03 April 2015 10:18
> > From: Yanjiang Jin <yanjiang.jin@windriver.com>
> >=20
> > do_div() expects the type of "n" to be uint64_t, define "lat_ns" as u64=
 to
> > avoid the below warning, also update its correlative operations and dat=
a.
> >=20
> > In file included from ./arch/powerpc/include/asm/div64.h:1:0,
> >                  from include/linux/kernel.h:124,
> >                  from include/linux/list.h:8,
> >                  from include/linux/timer.h:4,
> >                  from drivers/net/ethernet/intel/e1000e/e1000.h:29,
> >                  from drivers/net/ethernet/intel/e1000e/ich8lan.c:59:
> > drivers/net/ethernet/intel/e1000e/ich8lan.c: In function 'e1000_platfor=
m_pm_pch_lpt':
> > include/asm-generic/div64.h:43:28: warning: comparison of distinct poin=
ter types lacks a cast [enabled
> > by default]
> >   (void)(((typeof((n)) *)0) =3D=3D ((uint64_t *)0)); \
> >                             ^
> > drivers/net/ethernet/intel/e1000e/ich8lan.c:1016:4: note: in expansion =
of macro 'do_div'
> >     do_div(lat_ns, speed);
> >=20
> > Signed-off-by: Yanjiang Jin <yanjiang.jin@windriver.com>
> > ---
> >  drivers/net/ethernet/intel/e1000e/ich8lan.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/=
ethernet/intel/e1000e/ich8lan.c
> > index 48b74a5..baab58b 100644
> > --- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
> > +++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> > @@ -982,8 +982,8 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000_h=
w *hw, bool link)
> >  		u16 speed, duplex, scale =3D 0;
> >  		u16 max_snoop, max_nosnoop;
> >  		u16 max_ltr_enc;	/* max LTR latency encoded */
> > -		s64 lat_ns;	/* latency (ns) */
> > -		s64 value;
> > +		u64 lat_ns;	/* latency (ns) */
> > +		u64 value;
> >  		u32 rxa;
> >=20
> >  		if (!hw->adapter->max_frame_size) {
> > @@ -1008,8 +1008,8 @@ static s32 e1000_platform_pm_pch_lpt(struct e1000=
_hw *hw, bool link)
> >  		 * 2^25*(2^10-1) ns.  The scale is encoded as 0=3D2^0ns,
> >  		 * 1=3D2^5ns, 2=3D2^10ns,...5=3D2^25ns.
> >  		 */
> > -		lat_ns =3D ((s64)rxa * 1024 -
> > -			  (2 * (s64)hw->adapter->max_frame_size)) * 8 * 1000;
> > +		lat_ns =3D ((u64)rxa * 1024 -
> > +			  (2 * (u64)hw->adapter->max_frame_size)) * 8 * 1000;
> >  		if (lat_ns < 0)
> >  			lat_ns =3D 0;
>=20
> The above change cannot be correct.
> You should be getting another error for testing an unsigned value be less=
 than 0.
>=20
> So I presume this wasn't even tested.
>=20

I found the same issue and I am putting together another patch to
resolve the issue that Yanjiang saw.

--=-4dLaWvVnUg81OubZRAc+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJW+uAAoJEOVv75VaS+3OmOgP/2scKSMjfv74L6rj1W46jv8d
qrNMj1Vtey4wU4UWncm3xsMi7DlIKlVLhl2RT1k+uZaICK5IqXrjPsYz6siJ512D
6nGR5eAejr5rSfyd/nW0WQGxkmSJmUh+pidM0Y+8WLjtlKmlY/P/WipkpwEfMPv2
Exp2qGIThRJwO1oYaoFR2Vjwva/yq9DH1/Nh9rZCRI0PX6+IaV3SCKbwBBq/wxhx
eoOQ3W3lW2YQri/eAb4WK2CgKqm2Ha2jjui62tJZqTK64l6LhGKOC0BuLpSsfud1
3LFUNvp+1o3t5BB6rCvVz4Lh9XX1pz2e5ZwtEjI2o71RStQytug9w1JUYUF+k1QN
DiPdcxMwrwKcam9cIGY7qHFV24IckgOrRGIEXT6zC74If8hZRLYVkeu7IvF15+ie
mJS7snY/DtEPwkPniLFheJbEMXboGc0RxLtIAef1Obkjx7GPsusWbdR7o8LgzPd2
l7h816Ws/1Iwz5eVFG7Tw+zdb8hxtPy60we6j+qoaKtOJzr/WsUw4x/VPrw7G6kF
jDFAc89rTuDiI2+vNAYWNAAAq9vRk6aEfRL5prEGfG8UxC2bUpBe3896bmdLfDLQ
s6P39Wb2jehECH3Ve+spNBXupc5y938iuHFS8MSsdbQHR0G85dZEsjMIcqBBnXdq
M/lb15UfNOoBYPnD/oHk
=LAAi
-----END PGP SIGNATURE-----

--=-4dLaWvVnUg81OubZRAc+--
