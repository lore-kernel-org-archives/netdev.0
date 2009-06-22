From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/HACK] net/compat/wext: allow sending different messages
 to compat tasks
Date: Mon, 22 Jun 2009 07:57:04 +0200
Message-ID: <1245650224.4180.5.camel@johannes.local>
References: <1245589835.5003.2.camel@johannes.local>
	 <200906220003.22458.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-OgOcFHhm4T8zG82A3Yj1"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:42688 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbZFVF5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 01:57:06 -0400
In-Reply-To: <200906220003.22458.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OgOcFHhm4T8zG82A3Yj1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-06-22 at 00:03 +0200, Arnd Bergmann wrote:
> On Sunday 21 June 2009, Johannes Berg wrote:
> > --- wireless-testing.orig/net/compat.c  2009-06-19 17:50:30.000000000 +=
0200
> > +++ wireless-testing/net/compat.c       2009-06-19 17:53:13.000000000 +=
0200
> > @@ -782,16 +782,18 @@ asmlinkage long compat_sys_socketcall(in
> >                 ret =3D sys_socketpair(a0, a1, a[2], compat_ptr(a[3]));
> >                 break;
> >         case SYS_SEND:
> > -               ret =3D sys_send(a0, compat_ptr(a1), a[2], a[3]);
> > +               ret =3D sys_send(a0, compat_ptr(a1), a[2], a[3] | MSG_C=
MSG_COMPAT);
> >                 break;
> >         case SYS_SENDTO:
> > -               ret =3D sys_sendto(a0, compat_ptr(a1), a[2], a[3], comp=
at_ptr(a[4]), a[5]);
> > +               ret =3D sys_sendto(a0, compat_ptr(a1), a[2], a[3] | MSG=
_CMSG_COMPAT,
> > +                                compat_ptr(a[4]), a[5]);
> >                 break;
> >         case SYS_RECV:
> > -               ret =3D sys_recv(a0, compat_ptr(a1), a[2], a[3]);
> > +               ret =3D sys_recv(a0, compat_ptr(a1), a[2], a[3] | MSG_C=
MSG_COMPAT);
> >                 break;
> >         case SYS_RECVFROM:
> > -               ret =3D sys_recvfrom(a0, compat_ptr(a1), a[2], a[3], co=
mpat_ptr(a[4]), compat_ptr(a[5]));
> > +               ret =3D sys_recvfrom(a0, compat_ptr(a1), a[2], a[3] | M=
SG_CMSG_COMPAT,
> > +                                  compat_ptr(a[4]), compat_ptr(a[5]));
> >                 break;
> >         case SYS_SHUTDOWN:
> >                 ret =3D sys_shutdown(a0,a1);
>=20
> I suppose if you do this, you also need to introduce a
> compat_sys_{send,sendto,recv,recvfrom} entry point
> for architectures that do not go through sys_socket but
> call sys_{send,sendto,recv,recvfrom} directly. I think
> this is only sparc and mips.

Thanks, good catch, I'll take a look. Since I only care about recv(from)
I guess it would be better to only do those.

johannes

--=-OgOcFHhm4T8zG82A3Yj1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKPx0sAAoJEODzc/N7+QmaUQwP/RCoU7lJM8u1ZpJvLUd6xmPR
4sgVDqOLVZql8VRp1WWnHw4jY0wyC3nX7UHqKFgSZNinWDADR06oejHzcRzwA3HM
e+6j+txKX8EdZQM+fLUBnSary7UMvNNwc5ayZt7Fv6WnZgPmD61BBvqI8LlcMGCg
j5bIn3l0OqV3Vrc3tyqu2hcduzBzEHPT0Ok9biSVbnKVdyrgPBTGQPOSC4Emfh5o
Zn4533EmqIn69tV1/vOyPzgCBcRXomdhlG0IAKUpDJe4s9GVZH/Wze9k8Kei5+8T
Iiwds4d2ap1eQVE1a6CyQ0D4yVHaywYRch+sjWpRFsZNrnj039dB8gUW2HWV3g8s
ivx4YbMyLuN0++8DONqq8//q/RHdZat3rIErjy/xOUCY5T6U6jStKlNCPJ0RL7O4
FAKEXGFIvLkZN3ekFtgWhwAYfnm53/qEGkLY0rOiDnTR8GdBcxGdTbBUEltVljAw
lggxpfGOkyI7y+KE4b2ChCZnN2FOR6O8zFXOHB9LO924T5iPNMdMAJfpotYjBMDK
jS3O18NWFI+sXYpFhqNxVYdnC4yMzBkSaxHPNUrqt/mB92Bj2AVHR6I18Fm1GgBN
KA0xVWS4WtPE0GCkZndsxyUVGRQZp+mUokV2qvh/pkQIOFWfMiWJsGXySKaeL5bf
X0gWSGUpKKWxc5v34cCW
=nFKK
-----END PGP SIGNATURE-----

--=-OgOcFHhm4T8zG82A3Yj1--

