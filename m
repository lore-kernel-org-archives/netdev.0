From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Thu, 10 Aug 2006 23:25:05 -0700
Message-ID: <44DC22C1.1060200@redhat.com>
References: <11551105592821@2ka.mipt.ru> <11551105602734@2ka.mipt.ru> <20060809152127.481fb346.akpm@osdl.org> <20060810061433.GA4689@2ka.mipt.ru> <20060810001844.ff5e7429.akpm@osdl.org> <20060810075047.GB24370@2ka.mipt.ru> <20060810010254.3b52682f.akpm@osdl.org> <20060810082235.GA21025@2ka.mipt.ru> <20060810175639.b64faaa9.akpm@osdl.org> <20060811061535.GA11230@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC33869A3785CC2384B9231F8"
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57251 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751617AbWHKGZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 02:25:35 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060811061535.GA11230@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC33869A3785CC2384B9231F8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Evgeniy Polyakov wrote:
> The main disadvantage is that all memory is allocated on the start even=

> if it will not be used later. I think dynamic grow is appropriate
> solution, since user will have that memory used anyway, since kevents
> are allocated,

If you _allocate_ memory at startup you're doing something wrong.  All
you should do is allocate address space.  Memory should be allocated
when it is needed.

Growing a memory region is always hard because it means you cannot keep
any addresses around and always have to reload a base pointer.  That's
not ideal.

Especially on 64-bit machines address space really is no limitation
anymore.  So, allocate as much as needed, allocate memory when it's
needed, and don't resize.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enigC33869A3785CC2384B9231F8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFE3CLB2ijCOnn/RHQRAnYcAJ4sTvU8E6lVmH15hgqgz3uTWnu7NwCgoqSw
uxIHlELeqovMVX6YYg7PKHI=
=C7gO
-----END PGP SIGNATURE-----

--------------enigC33869A3785CC2384B9231F8--
