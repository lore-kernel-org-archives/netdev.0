From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [patch] ser_gigaset: return -ENOMEM on error instead of success
Date: Wed, 7 Dec 2016 21:57:54 +0100
Message-ID: <d8eb1f69-e68e-7792-00de-b14e6bac1606@imap.cc>
References: <20161207112203.GC5507@elgon.mountain>
 <1481137583.12596.19.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="cCaNQVSM1qMreCm58ApjrbMVmqjhbqHqW"
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>,
        Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:42168 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752253AbcLGVIc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 16:08:32 -0500
In-Reply-To: <1481137583.12596.19.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cCaNQVSM1qMreCm58ApjrbMVmqjhbqHqW
Content-Type: multipart/mixed; boundary="xMP98nvWSUeejPJfmk2DUea1l5wqW1O6i";
 protected-headers="v1"
From: Tilman Schmidt <tilman@imap.cc>
To: Paul Bolle <pebolle@tiscali.nl>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, "David S. Miller"
 <davem@davemloft.net>, gigaset307x-common@lists.sourceforge.net,
 netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Message-ID: <d8eb1f69-e68e-7792-00de-b14e6bac1606@imap.cc>
Subject: Re: [patch] ser_gigaset: return -ENOMEM on error instead of success
References: <20161207112203.GC5507@elgon.mountain>
 <1481137583.12596.19.camel@tiscali.nl>
In-Reply-To: <1481137583.12596.19.camel@tiscali.nl>

--xMP98nvWSUeejPJfmk2DUea1l5wqW1O6i
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 07.12.2016 um 20:06 schrieb Paul Bolle:
> On Wed, 2016-12-07 at 14:22 +0300, Dan Carpenter wrote:
>> If we can't allocate the resources in gigaset_initdriver() then we
>> should return -ENOMEM instead of zero.
>=20
> That's entirely correct.

Agree.

> I'll be back (probably tomorrow) after a short test to see whether this=
 really
> needs to go into stable. It almost certainly should, but I'd like to fi=
rst see
> the mess the current code leaves behind once gigaset_initdriver() fails=
 before
> saying so.

Not much of a mess, I reckon. Everything that has been allocated and
registered up to that point is properly deallocated and unregistered.
The code just fails to tell the kernel that module initialization has
failed, so the module remains loaded even though it can never be
called because it isn't hooked anywhere. That's a nuisance and a
waste of RAM, but not much more.

HTH
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--xMP98nvWSUeejPJfmk2DUea1l5wqW1O6i--

--cCaNQVSM1qMreCm58ApjrbMVmqjhbqHqW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJYSHfcAAoJEFPuqx0v+F+qczEIAKdfdnnYDtWQ2JWeZ7bksxi/
TlqeY4fACemoYn4IawC+F/1aQ3Txjxk+AhyknnKGYRPeZj3rU8LDx3nfEJRj6cGW
+YJNDuwcXnVFyNLLH4XTvQWamjb7XkZu0HT3xUhsFI8jwuIMQL9YXwiq/9O6KOmz
J8ndulwhthe/26Jn5HlSJkwNBQlkjRTKg7ITm0FrVfbovliar5ZzwfneKnCcp+rX
e9d48ylqltN+ChCSXzJjUt9z2FzXtANQL4WdWAHNt9vF+iIx9XD8QdBxpmRzKWBh
/l3ac94gkDn6Why2VtRpFF7dskF1HNa5Qgs1tCv7K7sCeyftrwRjJBxoCrz83W0=
=63u4
-----END PGP SIGNATURE-----

--cCaNQVSM1qMreCm58ApjrbMVmqjhbqHqW--
