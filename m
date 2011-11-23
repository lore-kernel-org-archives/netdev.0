From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] isdn: make sure strings are null terminated
Date: Wed, 23 Nov 2011 10:16:20 +0300
Message-ID: <20111123071619.GB3363@mwanda>
References: <20111123064204.GA6871@elgon.mountain>
 <1322031811.1298.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1UWUbFP1cBYEclgG"
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:45433 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459Ab1KWHQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 02:16:13 -0500
Content-Disposition: inline
In-Reply-To: <1322031811.1298.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1UWUbFP1cBYEclgG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 23, 2011 at 08:03:31AM +0100, Eric Dumazet wrote:
> > +			if (strlen(dioctl.cf_ctrl.msn) >=3D sizeof(dioctl.cf_ctrl.msn))
> > +				return -EINVAL;
>=20
> This looks buggy.
>=20
> If string is not null terminated, how strlen() will stop you from going
> out of bounds, and trigger some run time checker ?
>=20
> strnlen() would be more effective...
>=20

Aw crap.  My first version used strnlen() and I redid it to be
simpler.  I just figured that it doesn't take long to hit a zeroed
u8.

I'll resend all three strlen() patches to use strnlen().

regards,
dan carpenter


--1UWUbFP1cBYEclgG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOzJ3DAAoJEOnZkXI/YHqR6dAP/3oUPQNgtLSihDzgS0bB6Ug/
F6h7+Y9oQ/JHS98066M7QkxGXfzYr5AX6Y7e96uSO1ucr6NjRTju02wd3MhvVMdn
qLF/8R+n/uh59SPxjqdn0ry0YbEzJlPMh7te6OaQxvzv77IEtacu3UvfEF3twA1Z
0vrVB1ZxxisjSL9XUyXcl7byzdx3fB0cseZZg1mpfsblTuhnF34mZr0eroVgrmrk
171AP/27fsETMrdAqKU49xu2la9eJbGcUHlQMQAWTmxrsiGBq+RAOpi172XpdaZ4
G5m5P6AfKe01WwSYXsGvfzOFQZNTS6zmAd0LopYlkT0pHOf8aT3o7ulvCLDpzuoy
HheoWEjLqFfCjZU9v8LRDhoX6g+ToWjtCN4H05oo7jg9dG614js4XSrgvPK0SStt
/4H3IdE3HJEIn3OatgDlWL3LQUsYPiS4A1DDCv1Pb8NS6OcY7cmJJ+f7cffJ0drb
AoA9Rf5IpIK0NxEbv3tmBTE3l96sCRUu2/u1FU0BzyHx4RcZgFdkS19zqwheI73N
469FZrhyd1DOFeOlAaurZ87Xx3JRwdno2KLgrh6Jn9m1CvO8V5yqT56vVV8vb2Oc
mbe3YlGjaRivguOiAVn/MjVuB2S0z2DkX6eTxU5D670tsTGARI4uW/YDxj9slIfj
zrmDmX4Nx/GTi1bBOrQL
=mdph
-----END PGP SIGNATURE-----

--1UWUbFP1cBYEclgG--
