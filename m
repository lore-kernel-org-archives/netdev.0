From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Configuring synchronous ethernet with ethtool?
Date: Sat, 04 Apr 2015 23:55:24 +0100
Message-ID: <1428188124.11260.105.camel@decadent.org.uk>
References: <20150317161128.GA8793@localhost.localdomain>
	 <1428155950.11260.66.camel@decadent.org.uk>
	 <20150404200344.GA4271@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ljovnRsVvUiSTxoSA+QI"
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58486 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752322AbbDDWzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 18:55:38 -0400
In-Reply-To: <20150404200344.GA4271@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ljovnRsVvUiSTxoSA+QI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2015-04-04 at 22:03 +0200, Richard Cochran wrote:
> On Sat, Apr 04, 2015 at 02:59:10PM +0100, Ben Hutchings wrote:
> > The 'manual' setting matches terminology in IEEE 802.3 (section 40.5.2)=
.
> > There's no mention of 'preferred' there but perhaps this switch will
> > claim to be a single-port if you say it should prefer slave mode.
>=20
> Thanks for the reference.  The switch I was talking about has control
> register 9 implemented exactly as described in 802.3, but the TRM
> description of bit 9.10 adds the word "prefer".
>=20
> > So, I like the idea but it should not be tied to SyncE only.
>=20
> Something like this?
>=20
>    | ethtool property        | effect             |
>    |-------------------------+--------------------|
>    | synce-mode =3D none       | 9.12 =3D 0           |

That's not 'none', it's just not forced.  This would be used for both
asynchronous operation and for synchronous operation with negotiated
clock mode.

>    | synce-mode =3D master     | 9.12 =3D 1, 9.11 =3D 1 |
>    | synce-mode =3D slave      | 9.12 =3D 1, 9.11 =3D 0 |

So there are four different modes that should be selectable through
ethtool:

- Asynchronous [100BASE-T only]
- Synchronous, automatic
- Synchronous, master
- Synchronous, slave

>    | port-type =3D multiport   | 9.10 =3D 1           |
>    | port-type =3D single-port | 9.10 =3D 0           |

For backward compatibility ethtool would also need to be able to report
'unknown' when the kernel or driver doesn't support this.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g

--=-ljovnRsVvUiSTxoSA+QI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSBr4ee/yOyVhhEJAQrTqQ//d4ljfmLKqaZPDLRhMZjBL8OKTQDfj2nX
JwAC2ekjFrfkG43SZ/cTR0lBMrcXjC+dh25kLdWd2Ct3aJHCxCsrCBbjYGor5lWy
GWoa53fE/+DmsUldfXo+HNblrXgvkA8reaNke9iUt0ieoMhdXuxnjAlK1qgF8rqb
qSSmqYEHBss1xTxTKVPTiniMNdQW9eR/+KzFn4JJ2CsENnUUpmWCiSV54WkRKKPt
yBIqi4e5mBbyPb++CfXshntmEfBYf0oj54enlckTbYR1nIpmw1QY78mzmIXwnuZg
eBzUqdVoJRk9LPyT3xHHSOQoqS2rCoCJGnV1aFvgiUJukQQ+Yk9O5kh05Kw3kyVB
Ce2A4VR1Hrq002u9XEn2Ltj1el9XsDf/hJ4YOeu5VSu1lpUnVg3Ij2vwKkXZmc/t
QCQzDeE5FbFBiihWpj14WCy5ANdNbdP9x98sRwbKlqMREwWCh8QKuCH7pD62xiP3
lx5m2DnCa0sdmjH/8b6bcqKrVHrWzTfS1TwNs66ATdgWm8UQNkvYovtjmjG/bTLh
xEQreio+VLH9au1QLdSwBUplbWzVB8CLHpkB6GSM/YA4IJOMNsXl/9/Ft2on21rq
aUR4OpbHtiFC/2s6/6DmFWWgRtalJxy1IPfpm1r9+LP6NjhdzZkMCc7n5ffYgZ0V
95zyCmV0Jps=
=XXR8
-----END PGP SIGNATURE-----

--=-ljovnRsVvUiSTxoSA+QI--
