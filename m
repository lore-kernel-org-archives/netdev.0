From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 03/12] ethtool.c: fix dump_regs heap
 corruption
Date: Mon, 07 Mar 2016 16:02:50 +0000
Message-ID: <1457366570.15205.18.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-4-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Cmo8PWOKUCB1pXMKQoUB"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43652 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752840AbcCGQDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:03:01 -0500
In-Reply-To: <1457138533-2417-4-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Cmo8PWOKUCB1pXMKQoUB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> The 'regs' pointer is owned by do_gregs(), but updated internally inside
> dump_regs() without propagating it back to do_gregs(): later free(regs)
> in do_gregs() reclaims the wrong area. This commit moves the realloc()
> inside do_gregs().

Wow, how did we ever get away with this?

Maybe no-one ever used this feature - it certainly makes very little
sense to save a register dump without the driver name or version
number, and then to assume that a loaded register dump matches the
running driver!

[...]
> @@ -2711,7 +2691,31 @@ static int do_gregs(struct cmd_context *ctx)
> =C2=A0		free(regs);
> =C2=A0		return 74;
> =C2=A0	}
> -	if (dump_regs(gregs_dump_raw, gregs_dump_hex, gregs_dump_file,
> +
> +	if ((!gregs_dump_raw) && (NULL !=3D gregs_dump_file)) {
[...]

Redundant parentheses, and the comparison is written the wrong way
round.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-Cmo8PWOKUCB1pXMKQoUB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3aYqAAoJEOe/yOyVhhEJV0UP/RpI3IV2aGQgPLdr4KfkFm1L
jgQUhZgs5D7P/J9Igjz7pKxBbSoalg3iWYy06aAM1gOfZil/uIo2BrR64cqBviw1
ETfTr+dYJcurO9AUWN/CoHmDcV2oWyRl9gMPOKqBPLdyes/beYExo+qSnWC+jyb+
5eT5nb/f1IQIwYOy/R5rv7od7Ukj1o4cbEaD8vZPuVvdY47E923q6I5ik5tqUMHk
gn8JBPk440FlwaZgXooOefaZsnmZfh/SVCMf8tDQS64121ctCeCzKKVHnRTPVZEz
3BjqEHjdaehdOIBsu0cGNyC5MryY34zpHJxCAJ6sDTJ2baQUpfwTl1zzXPlAARbq
6fjXMyiBxE2g71cqgBhwYw5p5wcAnfm31IJ7rcCFQcu0p46hjC1iossvHz+QIyC0
WUpXdIEO+3/UzEDuXRBr4BBl0nHhTzuZ3RJ+tdZkYmOFMepsLawwOhIPpT+o0Y4n
xE2D6V7tj6QlGazoDJfYCJosMASWxDRLOR88RXU/u0mX7rxaVR66e47JObNOQB3p
Crs1adpN2vyqQUG6VJjaY/As4vuzy10xkE0ACMziJldgPLTdcsCmsem2BOWDabNA
KadHXkgoVmCsFgnSg6AAb6QSMHevxg2L5gnvyFHwyv+Kj1pX5kkTqQwq1upnpX9U
YmEwO2QhRjorF/wrgKz6
=8Tuk
-----END PGP SIGNATURE-----

--=-Cmo8PWOKUCB1pXMKQoUB--
