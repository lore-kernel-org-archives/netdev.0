From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next PATCH] ethtool: Add support for SCTP verification tag
 in Rx NFC
Date: Mon, 22 Aug 2016 14:05:50 +0100
Message-ID: <1471871150.13300.137.camel@decadent.org.uk>
References: <147164234934.15412.10180837031828143039.stgit@ahduyck-desk.amr.corp.intel.com>
         <1471738910.13300.114.camel@decadent.org.uk>
         <CAKgT0UcPgOzgH3S6WHLUx4H_DXovHKGj=g57rYxGVp2WiYOEcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-uKSLtYVEmNcDsVnZeSP8"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55219 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755263AbcHVNGG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:06:06 -0400
In-Reply-To: <CAKgT0UcPgOzgH3S6WHLUx4H_DXovHKGj=g57rYxGVp2WiYOEcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uKSLtYVEmNcDsVnZeSP8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2016-08-20 at 18:56 -0700, Alexander Duyck wrote:
> > On Sat, Aug 20, 2016 at 5:21 PM, Ben Hutchings <ben@decadent.org.uk> wr=
ote:
> >=20
> > On Fri, 2016-08-19 at 14:32 -0700, Alexander Duyck wrote:
> > >=20
> > > The i40e hardware has support for SCTP filtering via Rx NFC however t=
he
> > > default configuration expects us to include the verification tag as a=
 part
> > > of the filter.=C2=A0=C2=A0In order to support that I need to be able =
to transfer that
> > > data through the ethtool interface via a new structure.
> > >=20
> > > This patch adds a new structure to allow us to pass the verification =
tag
> > > for IPv4 or IPv6 SCTP traffic.
> > [...]
> >=20
> > This looks like an incompatible ABI change.=C2=A0=C2=A0I suppose it cou=
ld be OK
> > if no drivers implemented flow steering for SCTP using the previously
> > specified structure, but have you checked that that is the case?
> >=20
> > Ben.
>=20
> Well the structure itself matches the TCP flow spec for the TCP flow
> sized portion.=C2=A0=C2=A0All I am doing with this patch is adding an ext=
ension
> to that which is still confined to the 52 byte limit of the flow
> > union.

But that extension will be ignored by any drivers that implemented the
API as previously defined. =C2=A0(If there aren't any, as I said, this
doesn't really matter.)

With previous extensions (everything in struct ethtool_flow_ext) we've
introduced new type flags to ensure that they won't be silently
ignored. =C2=A0You could add a new extended-SCTP type value for the same
reason.

[...]
> One thing I could do if you would like would be to spin up another
> patch to force the kernel to return -EINVAL if we are masking in
> fields that are out of bounds for the flow specification.=C2=A0=C2=A0That=
 way we
> can handle this=C2=A0=C2=A0a bit more concisely in the future should we e=
nd up
> > having to extend any other flow specifications.

It's too late to do that now.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.
--=-uKSLtYVEmNcDsVnZeSP8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXuvivAAoJEOe/yOyVhhEJ2hMQAKfD9MAx6PXP47xv/jGlXksr
uLrGdoIYmcZdQbslHSNu0xnpV95ueiIRHuuLMLXndBziIoVmwqbxd47pr5UFiq7b
OjV+Jt+rA1r1+DkW3pH+qRVIfQU2AaMt68pEphojZZY1QJ0o7r9XhmPeMnNs2fSA
WEZnd47q+puRugnXPLLROsmG4VzG2UeUkz/4D6xCAo9jUfWJ4utGSpRclZUouCOX
GhENTaY0kJLb5P+sqQNrmHBw3KhV+PjQH/F2EMDyjeFGo+GA77MrHQF2UNbV4/NK
7PjLFBmbzgh1HKRFcJkBABKaklhbuvhxVgNdR+4CR8rZ3Eam0LR4PtMTNa/36DPU
1UKtzni2//+3IvGNt8gczzgY+mcRqyXSqhKzNwmDpMIHYKIekWb/Fr9kiQR+X0Qq
v+PM4mtR/qxiqHokUpndxyFGs7Hgqbj8QZ4i9VSuWsFbggH2m1LMQDvuwEj/Blnu
8uGtlsxVIZrt2vzcA0VW3HxCFKec3IFh8Aw3JeLJ5pnH2CEanMunQ8Eha/wW0ATQ
bhpvyuoEDyZFA60VUmxa9OerfoXQMUqUqnjviZVve9EjYNh0A4xkEYjHKjme2oWk
tNpt2gXqnhtW1X3eMylMk0knaf2olHf95xylFNkhcSAQSC7z1o/11rcEjlKzS1wE
XTNKbvoiNrguPyuLEKGx
=TDiv
-----END PGP SIGNATURE-----

--=-uKSLtYVEmNcDsVnZeSP8--
