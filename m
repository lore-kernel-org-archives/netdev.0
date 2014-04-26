From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 9/9 v2] net: Add sysctl to trust checksum_complete
Date: Sat, 26 Apr 2014 22:58:46 +0100
Message-ID: <1398549526.16049.20.camel@deadeye.wl.decadent.org.uk>
References: <alpine.DEB.2.02.1404261402390.27405@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4Xqh09QtAdCNol/ZQ0MU"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39386 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751900AbaDZV64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:58:56 -0400
In-Reply-To: <alpine.DEB.2.02.1404261402390.27405@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4Xqh09QtAdCNol/ZQ0MU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-04-26 at 14:26 -0700, Tom Herbert wrote:
> Currently if a device provides CHECKSUM_COMPLETE but the checksum
> is calculated to be invalid we recompute the checksum and try
> again in software. On the other hand, if device returns
> CHECKSUM_UNNECESSARY we implicitly trust it and don't verify what it
> did. This seems backwards!
>=20
> Add a sysctl to trust the device and report an invalid checksum when
> CHECKSUM_COMPLETE shows it is incorrect. sysctl defaults to enabled.
[...]

I think the sysctl and variable names need an '_error' or '_err' on the
end, to distinguish this from the NETIF_F_RXCSUM feature flag.

The new sysctl also needs to be documented, again making that
distinction clear.

Finally, if we're going to start trusting device checksum errors,
perhaps there should be a way to indicate a checksum error from a device
that only reports a checksum good/bad flag.  I do understand that such
devices are more likely to have bugs in checksum validation, though.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g

--=-4Xqh09QtAdCNol/ZQ0MU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1wsFue/yOyVhhEJAQoJAg/9FtJrIeSaBaTuOTrJZ/rodtjIJ2/r2N54
/A0LPvlAL14vMXnqQA+w/Ma3jFm1VFCZr6w9FtEk7/yOoB6E04HWNMWPyXrSGvFZ
D80a7IcyRTpkdmlE9Im16RuH85vtBClbRNMpb3OUp/6Yl7IOTSVStvIAKobSIj6/
euS8veFzfS0HwRrZMvHAzvdrNja6b0tPDcTdCPvSoP5mUhl/YecCjlBiylCmPGS0
hrre37i/nqYgGOxr5lw0tkhm4fBnEwueKnn9TfeqWYtHqCT9xq7Z9mjji0FB+cgw
dUBDn0bo28lb3aIeT7xieoS8RV5uRW2MzBmXvDwkza02JhWXU2BZOL2lbPmVbfzS
ey1y7pD/Oa+wKROyksqw/fKltOPXbHi9peP7TtKRGXhZKybWzLOlNLmqhZNXBhwt
G/BjreaKR8vKE8qXDAH6Qgm+8fNqBt270QbVr3mhqohNKukzgnTgfDLYndAxl7Gz
KkXg9U3Z6KnBUr7gpu2+rEYL+ye+pedR3+fXDI3ZFc/ynwYFpb5A0Gvxn3o3f85Y
MJUs5WLjOi59SilYOTkSxRs/KMGMehIBGxyD+IXCnVcQMaohoVS61TTxbRKp7/dv
+J0UBUjaY4IBtqNggmQ0ANiG8RForhjksh3FavwNXNQSbN+SH8n1cEOoWaP5IY5a
U3QJo6rhlXQ=
=rwbn
-----END PGP SIGNATURE-----

--=-4Xqh09QtAdCNol/ZQ0MU--
