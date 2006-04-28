From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 17/32] rt2x00: Put net_device structure in data_ring
Date: Fri, 28 Apr 2006 15:41:16 +0200
Message-ID: <200604281541.16696.IvDoorn@gmail.com>
References: <200604280003.09753.IvDoorn@gmail.com> <200604281345.22006.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5975824.NjeWX2kAXi";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:57122 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030399AbWD1NkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 09:40:07 -0400
Received: by nproxy.gmail.com with SMTP id n29so1581049nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 06:40:06 -0700 (PDT)
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200604281345.22006.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5975824.NjeWX2kAXi
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 13:45, Ingo Oeser wrote:
> Hi Ivo,
>=20
> Ivo van Doorn wrote:
> > diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt240=
0pci.c wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400p=
ci.c
> > --- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	=
2006-04-27 21:48:21.000000000 +0200
> > +++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400=
pci.c	2006-04-27 21:49:08.000000000 +0200
> > @@ -760,10 +760,8 @@ rt2400pci_write_tx_desc(
> >  static void
> >  rt2400pci_beacondone(void *data)
> >  {
> > -	struct data_ring	*ring =3D (struct data_ring*)data;
> > -	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
> > -	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
> > -	struct sk_buff		*skb;
> > +	struct data_ring		*ring =3D (struct data_ring*)data;
>=20
> No need for a cast here.=20
> In C you can cast from any struct pointer to void pointer and back
> without problems.
>=20
> > @@ -784,8 +782,8 @@ static void
> >  rt2400pci_rxdone(void *data)
> >  {
> >  	struct data_ring	*ring =3D (struct data_ring*)data;
>=20
> No need for casting.
>=20
> > @@ -835,8 +834,8 @@ static void
> >  rt2400pci_txdone(void *data)
> >  {
> >  	struct data_ring	*ring =3D (struct data_ring*)data;
>=20
> No need for casting.
>=20
> > diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt250=
0pci.c wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500p=
ci.c
> > --- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	=
2006-04-27 21:48:21.000000000 +0200
> > +++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500=
pci.c	2006-04-27 21:49:08.000000000 +0200
> > @@ -834,10 +834,8 @@ rt2500pci_write_tx_desc(
> >  static void
> >  rt2500pci_beacondone(void *data)
> >  {
> > -	struct data_ring	*ring =3D (struct data_ring*)data;
> > -	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
> > -	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
> > -	struct sk_buff		*skb;
> > +	struct data_ring		*ring =3D (struct data_ring*)data;
>=20
> No need for casting.
>=20
> Many more of them.
>=20
> I guess you could just do a fgrep for "*ring =3D (struct data_ring*)data;"

Thanks,

Not only the data_ring has unneeded casts, but they are also found on some =
other locations.
I'll create a patch that removes them all.=20

--nextPart5975824.NjeWX2kAXi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUht8aqndE37Em0gRAhtGAJ45aHWg20ikgKwntvhcNdTchnnzjQCdGBWp
N3YGNzG3qTw2lhP/SrHqnNk=
=5pj0
-----END PGP SIGNATURE-----

--nextPart5975824.NjeWX2kAXi--
