From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to real
 device.
Date: Sun, 23 Nov 2014 17:19:59 +0000
Message-ID: <1416763199.7215.53.camel@decadent.org.uk>
References: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
	 <1416712512.7215.34.camel@decadent.org.uk> <20141123160533.GA4562@netboy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pLh/CSQTyO0XxRKWnHwM"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48609 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751419AbaKWRUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 12:20:13 -0500
In-Reply-To: <20141123160533.GA4562@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pLh/CSQTyO0XxRKWnHwM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-11-23 at 17:05 +0100, Richard Cochran wrote:
> On Sun, Nov 23, 2014 at 03:15:12AM +0000, Ben Hutchings wrote:
> > This assumes that the same PTP capabilities apply to VLAN-tagged frames=
.
> > I don't think it's at all safe to assume that RX filter modes other tha=
n
> > HWTSTAMP_FILTER_ALL will include VLAN-tagged frames.  I think it is
> > necessary to define additional modes that explicitly include VLAN-tagge=
d
> > frames.
>=20
> Unsafe? How?

I mean that the assumption is wrong in general.  So these changes will
result in silent failure to enable RX timestamps, on some devices.

> Do you mean that some HW cannot identify and time stamp PTP frames
> when VLAN tagged? That is surely disappointing for people who shell
> out money for such cards, but it is hardly unsafe.
>
> > I also disagree in general that reconfiguring a VLAN device should make
> > changes to the underlying device that affect more than just that VLAN,
> > i.e. SIOCSHWTSTAMP should not be passed through.  SIOCGHWTSTAMP could b=
e
> > passed through, but rx_filter would need adjustment (VLAN-tagged modes
> > on the underlying devices become untagged modes on the VLAN device).
>=20
> The whole filter list with every last combination (at least, the ones
> at the time) came directly from a early, limited HW design.  Sane,
> modern PTP hardware provides time stamps regardless of whether a frame
> is VLAN tagged or not.

I would hope so.  However, this is non-standard - IEEE802.1AS
*explicitly forbids* the use of VLAN tags.  Linux's software PTP
classifier also doesn't yet handle 802.1ad VLAN tags.

> I don't see any reason not to make our stack even more ugly just to cater
> to broken hardware.

So failure to implement a non-standard extension is now 'broken'?

> I have nothing against adding VLAN to the SIOCGHWTSTAMP list, because
> the hardware people *really* use all have:
>=20
> 	HWTSTAMP_TX_ON, and
> 	HWTSTAMP_FILTER_ALL, or=20
> 	HWTSTAMP_FILTER_PTP_V2_EVENT,
>=20
> So adding more won't hurt. (But it won't help either. If your HW
> cannot time stamp Layer2 and you transmit Layer2, you simply never get
> a time stamp.)
>
> But please don't hold up progress just for this sort of thing.

This is progress for some devices, false advertising for others.

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-pLh/CSQTyO0XxRKWnHwM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHIXROe/yOyVhhEJAQpU8A//RbeGA4S/gwrrZDYJKvkMOl43PhMO5+E/
RfJDiVNq8ux7jEgnR0X57CGYEwTHOz5zzwDwQcAJMdXX3l0psstafLnYOF/pUd9d
L1YDf4DqCQ6C8CLJXFZzhetb9suJrlFq2O0CEEUuo5xaPATVQe8qGMsw4sCXTlF8
SX12JqcxX6wqgW7dQ/ckKixvh1JcMicKPZhn8rNRGVRVEzxXlwWSfTJm4PLYIDLF
NUww7x7D0RA7WpygMFfU/ggwjGyv+jfulFjdWpn0hY0mxaG4woTB2xObOw6z5jc4
OUbv4bbYIR9qTO4EafmHX4tJe+/y3hvLmaS0HPMR0uPv94JhDgMhbvsD5F4JBYUb
YQz/ETNE3v+NhpTOpqP+V7h84uUzPBSG7SpWltNpk9tlTriT9iziYgbKcdENkR40
pfb8oMJkxppZ14aLBJwAIV9+O7DKyQgDzN5OuL7J176bHGBYtpYc2zSGp5KCs5ji
uOtXA44VpXwIr+Tl07MECi5z+7VDEV5llEZFUfENHoxek/fsew+d+iDj1oRhGIc9
WDNaUNu/oj6IFao0DNp73cuF64vEQQceuWsgNRxzVMbL7ZYr5IebhZ9/uuXPxupa
xzbUhTnb7I4ubERuKOGOMF98LiqWLTiuprUn2WBvq9HIN07LefMZYZYG2LgMs7gu
I2bXLzzqEPw=
=kywK
-----END PGP SIGNATURE-----

--=-pLh/CSQTyO0XxRKWnHwM--
