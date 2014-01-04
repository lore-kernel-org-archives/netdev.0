From: Thomas Haller <thaller@redhat.com>
Subject: Re: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Sat, 04 Jan 2014 12:21:51 +0100
Message-ID: <1388834511.7407.5.camel@weing>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
	 <20140102172949.GF22494@order.stressinduktion.org>
	 <20140104104331.GB9295@minipsycho.orion>
	 <20140104105515.GA25828@order.stressinduktion.org>
	 <20140104110557.GD9295@minipsycho.orion>
	 <20140104111546.GB25828@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-dDZDvO35hsnZiLekZsrY"
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751943AbaADLWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 06:22:05 -0500
In-Reply-To: <20140104111546.GB25828@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dDZDvO35hsnZiLekZsrY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

On Sat, 2014-01-04 at 12:15 +0100, Hannes Frederic Sowa wrote:
> On Sat, Jan 04, 2014 at 12:05:57PM +0100, Jiri Pirko wrote:
> > Sure. NM should set use_tempaddr accordingly. You are right that kernel
> > generate temporary adresses, but only for the prefixes received via
> > neighbor discovery (see addrconf_prefix_rcv). The ones that are set by
> > hand are not handled. That is the reason we introduced IFA_F_MANAGETEMP=
ADDR.
>=20
> Ah, sorry. So NM sets use_tempaddr =3D=3D 2 but disables accept_ra? That'=
s fine,
> sorry to bother!

yes, that is the plan. use_tempaddr is to configure the preference for
address selection, and without accept_ra, the kernel will not add
autoconf addresses himself -- only NM adds them with
IFA_F_MANAGETEMPADDR. I think this will work out fine.

>=20
> > >So currently privacy addresses are correctly installed, but we cannot =
control
> > >if we want prefer them to global addresses for outgoing connections wh=
ere the
> > >socket is not bound to a specific address.
> > >
> > >Also, I saw that NetworkManager switched to install autoconf addresses
> > >as /128, doesn't this break with IFA_F_MANAGETEMPADDR, as you expect a=
 /64
> > >prefixlen?
> >=20
> > /64 is required
>=20
> Ok, currently NM seems to "violate" that as it installs autoconf addresse=
s
> with 128 prefixlen, so IFA_F_MANAGETEMPADDR should not work on them.
> (currently observed on Fedora 20).

True, I noticed that too. I think that is a bug in NM to add the
addresses as /128. Probably, we will fix that soon.


Thomas

--=-dDZDvO35hsnZiLekZsrY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJSx+7PAAoJECnCNm5N/FcoKp8QAKdgGqRFSCvk76jS1PiZAbXV
YILnj18/1KGLGdadowJpKYnZQDFGmSJuZO1oDg10seFDO5UoUF61/abAHOcqYBJj
uAFkbJsDiHn0mS6aMyyTWYtJov2vsfI1zR3opIacWYHXblzWemz2vYphy8RAcElL
hKjLq81rrPaMpMAL/LZkgeV1OP5VpVokOpnE9BqL8ABB4svhm/zgdKqaPKae4mYd
He39IVaGWq9Voi3Qzu08sWbn5iLI4NWP27ypGC2KAjUmN6vkPn7LOSN4kn/j+2go
hYIiYGyz23Fw9kqqzYg5/4ijWCXaqWFr1o8S9KGyptE3ni7j2E5bXxEiarsG4b/P
T+eRntoi+h2ECwQPOVIhnL8krRh+d047DLzA6QcWqYHPp17uWDFexfF1eWQiaeXK
vfFZSGhgVSsBci3xFuyPNQqoKp9MTinHLfk9JApP37ZeQJ9SP38m6jfkozwaga+e
uPbruDIzfC6n9XvA8jCy5idEAL5q27iYKuqPgJRc8RFa5L1B0SdW9iIaKj8xMex/
WERb+YT0byZkRJSAPv9zDx+hXnyHzdQM1qX7WSc96lfyNVxag7HlO5RjZjsyt9jY
ZC9XocX3CYZ5BSKPMYLVy+LMLmoF/W0eUkR6ZtQjmlXSYefiXYl5q82DnIa7CUow
aQ+j1d8P7jgCBj14lRK1
=6qHC
-----END PGP SIGNATURE-----

--=-dDZDvO35hsnZiLekZsrY--
