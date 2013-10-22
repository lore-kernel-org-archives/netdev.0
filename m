From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: Reduce memory consumption with larger page sizes
Date: Tue, 22 Oct 2013 03:23:33 -0700
Message-ID: <1382437413.6455.7.camel@jtkirshe-mobl>
References: <20131022103757.162f1a79@kryten>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qk3fPlLRJ4ai9vy6rDWG"
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22498 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab3JVKXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 06:23:34 -0400
In-Reply-To: <20131022103757.162f1a79@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qk3fPlLRJ4ai9vy6rDWG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-10-22 at 10:37 +1100, Anton Blanchard wrote:
> The ixgbe driver allocates pages for its receive rings. It currently
> uses 512 pages, regardless of page size. During receive handling it
> adds the unused part of the page back into the rx ring, avoiding the
> need for a new allocation.
>=20
> On a ppc64 box with 64 threads and 64kB pages, we end up with
> 512 entries * 64 rx queues * 64kB =3D 2GB memory used. Even more of a
> concern is that we use up 2GB of IOMMU space in order to map all this
> memory.
>=20
> The driver makes a number of decisions based on if PAGE_SIZE is less
> than 8kB, so use this as the breakpoint and only allocate 128 entries
> on 8kB or larger page sizes.
>=20
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
>=20
> Jeff: The breakpoint and the ring size I chose was pretty arbitrary,
> feel free to adjust as you see fit. Our main concern is we get that
> 2GB
> consumption down to something more reasonable :)

Thanks Anton, I will add your patch to my queue.

--=-qk3fPlLRJ4ai9vy6rDWG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSZlIlAAoJEOVv75VaS+3O1RYP/26RuPRtSNp0kRMzu05oDk+O
NJ2GujAucz6XJsSkfnkLftbIeZEV3Kmkufmlyo/d92T6Xk4d7OqwUMYkn07LrYwq
HWsUFWKVkDaYo9tr7nNNGG+QM6H/ZB+vhvpXApbCy49GAZoIyCSjUH3OOfInbiiO
lSuq9GgxCvls9lE+J4Or1BaojVHv0p2CRXsAU7N/CYnZIWVFzmAgfnz8Omg/G0CS
itrXJkgzO8O6nkXjlpcoDXdSnO9bkbT7y4japs1zg6FgVy/mPoeiXYes8TbK/NTj
PoJaxpffhkGVrNthgukFJbFa45WPw6mEPvoEy8DKT7axufxDf/vut6ZrWTPXol10
0+zf3qeLX1zD7IvuW/3QCUJ19jujP4jOYhT8sqH5Dl9uDlfEuz7PWwGwZj/MCQ4M
i9bJyGa2smIoBl5KhfRMpmMXQtumUYJRDvGCl8hMH4dFMhkHVqbPX+HRKSDXMnb/
Pwr5yDnlThLzk1IbBfpK5Xa6EMeH5t9gWAQ9wpBurfipwuNkJU6TyMlPb2c9HIJS
XlZLVdg/Er+JhcLvPGlIAWD29HSUTZ0n7ZssbFQKsJt4oJe3hXjo0b1dtkTKE+rR
leZbmN7ujcvMwoNMPQWGky11r88EL461pSMZXRlNgxLf7B0eg/fFXERSqubpzvbc
MRRqI5TyaxPCim3KhNpI
=N2yM
-----END PGP SIGNATURE-----

--=-qk3fPlLRJ4ai9vy6rDWG--
