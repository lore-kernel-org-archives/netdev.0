From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: ethtool NFC/ntuple API questions
Date: Wed, 20 Jan 2016 18:07:03 +0000
Message-ID: <1453313223.3734.63.camel@decadent.org.uk>
References: <569FBF9D.40002@solarflare.com>
	 <CAKgT0Ud1OprxqjYQC4NrFmRyhrG4x1G2=dWZEKwW866XAyW-eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-saSZRqVz1yZi2i0JD66K"
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53928 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753255AbcATSHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 13:07:19 -0500
In-Reply-To: <CAKgT0Ud1OprxqjYQC4NrFmRyhrG4x1G2=dWZEKwW866XAyW-eA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-saSZRqVz1yZi2i0JD66K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-01-20 at 09:53 -0800, Alexander Duyck wrote:
> On Wed, Jan 20, 2016 at 9:10 AM, Edward Cree <ecree@solarflare.com> wrote=
:
> > I'm looking into adding IPv6 support to the ethtool flow steering API.=
=C2=A0=C2=A0But,
> > I don't know "the unfortunate history of and subtle differences between=
 the
> > RX n-tuple versus RX NFC commands".=C2=A0=C2=A0In particular, would I n=
eed to add IPv6
> > support to both of them, or only one?=C2=A0=C2=A0If one would be suffic=
ient, which one
> > is preferred?
>=20
> I'd say just focus on Rx NFC.=C2=A0=C2=A0The NTUPLE interface is only rea=
lly
> used for legacy support on ixgbe if I recall correctly.

sfc also supported it for a while.

> The original
> implementation was badly broken, but because it went out we are stuck
> supporting it.=C2=A0=C2=A0Any new features can be added to the Rx NFC sin=
ce that
> is the interface that has the ability to both set and get filters.

Right. =C2=A0In fact maybe the ntuple stuff could be removed from the UAPI
headers given it's no longer part of the actual UAPI.

> > Also, is it necessary to duplicate the profusion of variants that the I=
Pv4
> > flow specs have (3x struct ethtool_tcpip4_spec, 2x struct
> > ethtool_ah_espip4_spec, and struct ethtool_usrip4_spec), or should I ju=
st
> > make one struct that contains all the fields from those (I would say "t=
he
> > union of their fields", but that might be confusing), and rely on flow_=
type
> > to indicate which fields are meaningful?
>=20
> I'd say just stick with the approach taken for IPv4 since it makes it
> much more readable.=C2=A0=C2=A0There were only really 4 types in use, but=
 we
> named each to make certain it was clear which one should be used for
> each type.=C2=A0=C2=A0To some extent the approach of relying on the flow_=
type is
> already in use, it is just made clearer by specifying which union to
> use for each type.

I don't mind one way or the other.

> > And, what exactly are the hdata fields in ethtool_flow_union and the
> > anonymous union in ethtool_rx_ntuple_flow_spec (they're not documented)=
 and
> > why are they different sizes?
>=20
> The hdata is essentially just padding that defines the entire region
> size.=C2=A0=C2=A0For the user interface we have to reserve some amount of=
 space,
> and in order to make the flow definitions compatible with NTUPLE we
> added extensions so that we could provide the information about the
> VLAN header if needed.
>=20
> The reason for the sizing difference is that the ethtool_flow_union is
> half of the flow definition, the other half is stored in
> ethtool_flow_ext.=C2=A0=C2=A0We shimmed ethtool_flow_ext into Rx NFC in o=
rder to
> work around the limitations of the NTUPLE filters.=C2=A0=C2=A0The structu=
re you
> probably should be looking at for comparison to NTUPLE is
> ethtool_rx_flow_spec, not ethtool_flow_union as that helps to tell the
> whole story.

Right. =C2=A0Further, we can extend ethtool_flow_ext *downwards* so long as
we shrink ethtool_flow_union by the same amount (and add a type flag
for the extension).

I already checked that ethtool_flow_union remained large enough to hold
IPv6 flow specs because I expected sfc would support them some day. :-)

Ben.

--=20
Ben Hutchings
The program is absolutely right; therefore, the computer must be wrong.
--=-saSZRqVz1yZi2i0JD66K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVp/Mx+e/yOyVhhEJAQrynw/+L6yRQK0ORdYvrvYRzfTb+I4/WmxOWH3u
v8zxeLqVLNOUyvkKiUk8nQn7uYg6eMW5I6VABQWpE0l+AvWjEqvuvl7armjZfC/i
Aiy7Sa+jMnmR/mZVIlqnWT0gwZ3N8FoBdRVBVZ2qMW2XHGCTqRDyttYeT8TG/y+p
d4cLuvXXqiM8J6d5hiR7SYUll2Jafod8eUqVgZrNVh1+B1rU6EgW2FkcFtE8IuX4
P7zls4QLTEoLNY8PvGlteNhLLsCPJ3aGKVFvZPHaMseBduCkKA2hiyYP0ceWItyD
csFfVXe/sIn2yODfhQeka5WkC8kpyKFaggUXiCunPCWdO+dt5IqI7XV3XDj1NJNZ
5df4w/ib5QzVlZv5D8cEa2/biv+UbdyRf5INh8VuCUNZxDLXTw10+7LEnJOvU4in
E4IiiOONMuBHywAtRrP3JXPIKMsNV/avLfVSuNS3p83J38jpdRx3FLpIuTlE9wPs
e68YGcJ5vJef6NSvAnXmjgE1UulHEIXzVChRkEcf6r26GgZkjD6Fsb1Sv8bEtQLd
f3m01DJROnPHc7INdaSklYZKw2PIbr1F9vcM6s7E/sG+uMz9XQByuDp9u4wMTcTn
3sA+LNGdPn+zfNBIZ2I04c17Lc2jzjKPBl6u4SGt0HYbPlUtDVl3bSh6TH9BBRzG
LpmFEabeGBQ=
=/lE6
-----END PGP SIGNATURE-----

--=-saSZRqVz1yZi2i0JD66K--
