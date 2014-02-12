From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: bnx2x + SR-IOV, no internal L2 switching
Date: Wed, 12 Feb 2014 23:10:40 +0000
Message-ID: <1392246640.15615.37.camel@deadeye.wl.decadent.org.uk>
References: <52FB7843.6050601@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BXFj5s/W+trGxJYUxp/e"
Cc: netdev@vger.kernel.org, Ariel Elior <ariele@broadcom.com>
To: yoann.juet@univ-nantes.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52955 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754039AbaBLXK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 18:10:58 -0500
In-Reply-To: <52FB7843.6050601@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BXFj5s/W+trGxJYUxp/e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-02-12 at 14:33 +0100, Yoann Juet wrote:
> Hi all,
>=20
> I'm conducting experiments on SR-IOV with Broadcom and Intel cards on=20
> debian/unstable with KVM hypervisor. On Broadcom cards (bnx2x module,=20
> BCM57810 devices), Virtual Functions (VFs) get running, Virtual Machines=
=20
> attached to such VFs inherit network connectivity with excellent=20
> performance.
>=20
> However, VMs attached to VFs on the Broadcom Physical Functions (PFs)=20
> behave like they were connected to an ancient hub, not a L2 switch. It=
=20
> is as if there was no internal L2 switching on the Broadcom card to=20
> process VF <-> VF or VF <-> PF communications. As a result, a VM sees=20
> all inbound/outbound traffic from/to others VMs as well as traffic=20
> destined to the PF (for instance, the physical ethX has an IP address).

Are you're using the ISC DHCP client, which puts the interface in
promiscuous mode?  If the Broadcom NIC supports promiscuous mode on VFs,
that may explain what you're seeing.

> On the other hand, everything works like a charm with Intel cards (ixgbe=
=20
> module, 82599EB devices). Traffic between VFs or VF/PF is switched=20
> internally by the card.

I think these VFs don't support promiscuous mode.  Anyway, the ixgbevf
driver silently ignores it.

Ben.

> I found very little literature about SR-IOV on Broadcom devices. I=20
> wonder if it's a normal behaviour, a misconfiguration on my side or=20
> perhaps a firmware/driver bug.
>=20
> Have you seen this issue before ?
>=20
> ---
> Kernel 3.12.9 (same behaviour with kernels 3.10.x)
> 	driver: bnx2x
> 	firmware-version: 7.8.17
> Debian/unstable
> 	libvirt 1.2.1
> 	QEMU 1.7.0
> ---
>=20
> Best regards,

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-BXFj5s/W+trGxJYUxp/e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvv/cOe/yOyVhhEJAQqcOxAAxi0K8DZjkmo+JD0hZ+k2BDrmUH+D2LZ3
RwZ7vIz8RODGby586E0v3vKd4z4K9G4HaiAokfqPKI7SXBkHfbmeU7/mCMt+jQVG
6McOukeoOz/QxFfJhx0K9v8iI2Z6AGFnjRQeSar8CJIjHv+X7DfZ19cEjIynBwOz
+lqXaDexmaXrJtOfwbzXLQ+6nYn8sctSojOKlu91tg9UVnSqb4VEGkWSd0tnwSwO
z0RnzgtCOb5oX0g+/ISj2NVPPhsQLa5Pe2UjRbbVWdUFd21GXPdkt3FzarJsvMxX
C+HKo4+SHGhxH4P3i006I7hoLQ5lvhW5zKdkn7tm2/ouF8fXq06yza5fW1MN8DxY
FThbNC0EqCn0S+fFFAUcqqAQJgKI/Xe6wslxY1dHsXkmQGJwwgCMY2HiuaOg9Dix
+o/BZm3TUWvOGUvIQyKb7RpUt2jLlKtr3k+ft7f9WOoWJbkKN9BGPgzorwNJLLSD
+lN1gOdRkSQKhgrnfSx8D9smD2uYahbRp3VepjKSAqsgYXRe/61jrA97kFoCpwiO
R3j54pX1blHi/lBDIKF6zD4NozQWj2m/aFQH8EIIMihOaksOTEQsn9aoo2XuI2zT
tM09vfOhaDIozj2TsFgE7eqMPFbg6kZs812HsO79De2MVrmDRnEt/3quIsRjybYN
A36yDoJC7xY=
=vYCe
-----END PGP SIGNATURE-----

--=-BXFj5s/W+trGxJYUxp/e--
