From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#855153: linux-image-4.9.0-1-amd64: kernel 4.9 does not
 check route protocol when deleting ipv6 routes
Date: Tue, 14 Feb 2017 19:02:44 +0000
Message-ID: <1487098964.2900.89.camel@decadent.org.uk>
References: <148709832872.5056.9337285234309493473.reportbug@octopus.ssx.li>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-c4wHBueGLBCpk61O/S/H"
Cc: Pascal Mathis <debian@web.smx.li>, 855153@bugs.debian.org,
        netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <148709832872.5056.9337285234309493473.reportbug@octopus.ssx.li>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-c4wHBueGLBCpk61O/S/H
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Please queue up:

commit c2ed1880fd61a998e3ce40254a99a2ad000f1a7d
Author: Mantas M <grawity@gmail.com>
Date:=C2=A0=C2=A0=C2=A0Fri Dec 16 10:30:59 2016 +0200

=C2=A0=C2=A0=C2=A0=C2=A0net: ipv6: check route protocol when deleting route=
s

for stable.

Ben.

On Tue, 2017-02-14 at 19:52 +0100, Pascal Mathis wrote:
> Package: src:linux
> Version: 4.9.6-3
> Severity: important
> Tags: ipv6
>=20
> Dear Debian Kernel Maintainers,
>=20
> when trying to delete an IPv6 route with a specific route protocol field
> in a kernel 4.9, the kernel does not actually check the protocol of the
> route and just deletes all the routes that match the other attributes.
>=20
> This leads to various issues with routing daemons, for example BIRD.
> E.g. when a BGP withdraw update is being received with a prefix matching
> a kernel route, both "proto bird" and "proto kernel" get deleted.
>=20
> The only workaround is currently to maintain a manual blacklist in the
> routing daemon, however a proper fix at kernel level would be definitely
> appreciated. As a patch was already committed to the Linux Kernel Git
> Repository, I recommend backporting into the Debian Stretch kernel, as
> the patch is both overseeable and easy to implement.
>=20
> The bug itself can be easily reproduced on any Linux running kernel
> version 4.9 or lower by executing these commands:
>=20
> ~$ ip -6 route add ff::/64 dev eth0 proto kernel
> ~$ ip -6 route
> (check the routing table, the newly added route is visible)
> ~$ ip -6 route del ff::/64 proto boot
> ~$ ip -6 route
> (the route is gone, although it should still be there!)
>=20
> A link to the Git commit fixing this specific issue can be found at the
> following URL and was already merged into kernel 4.10 since rc1:
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?i=
d=3Dc2ed1880fd61a998e3ce40254a99a2ad000f1a7d
[...]

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.


--=-c4wHBueGLBCpk61O/S/H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlijVFQACgkQ57/I7JWG
EQmmXw/8DFdvQjupE0wncgeaeVFACf40/jGzZcfqNPL5Zs7eJc3lmmgkZNFSL7wr
M0jR1xyLrXTlDMH6gCYKNMaOxio33+NWdDjYA4WznUTYqFUtdcX/23MqwhefbmEp
JQ2za99o6RqeJkf9WYC9vEu9GyHkErg/o1fzJuclB1jO3Rd4CE7vHQGSM2K/pDZc
krebsMSqJeVTVKSge1PqNX0LVJXUiy519SAfFhnpSKeaoA5bgvt7pb6CXJacL3+J
Ivna9k2fLSfztC8gCB+j49C7BIxzRhjFqokKdlm3QBshgDg932FxioBm0uv4FvNa
wdYsf5aHqIlgksVZ1/0VUytuk2I0+FQS7wonl56lET+Rlmwv4S4rYnFjGQA+/UI5
7DziTzBnlTF6kyAuKVGPE1+jgyZ2XSfxNMxqBKZJAcO33iYYeZwv//bNkEc7PR43
fsIPYzXVoLf9E8j4Ga9V2aKuN3XhbONvbAJ4xHIPg9Me3NFXuikqTMxuSnHv8S7F
LbavkjamsmiIT2c2SVx9DWzsY6lSyDhGSxv/I4K0Cga8TaeNEydCtQYXsXhxyKnt
MajK/AnHYO0Pi8nf8EMvJbcHn7TO0ZEcasGUsAAYTnuWGdX2eehaTlWy+o0BDIqF
UzWTz1mlk20soiC4Mo+avKhxEPL+tvIfbXqM7f3eXRIYmNtjHjQ=
=r959
-----END PGP SIGNATURE-----

--=-c4wHBueGLBCpk61O/S/H--
