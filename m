From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Porting ethernet over spi driver
Date: Tue, 22 Apr 2014 03:22:08 +0100
Message-ID: <1398133328.3624.186.camel@deadeye.wl.decadent.org.uk>
References: <5350ED9E.6080103@lategoodbye.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PaswF9fuO3itSyoUxu1r"
Cc: netdev@vger.kernel.org
To: Stefan Wahren <info@lategoodbye.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51756 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751236AbaDVCWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 22:22:20 -0400
In-Reply-To: <5350ED9E.6080103@lategoodbye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PaswF9fuO3itSyoUxu1r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-04-18 at 11:17 +0200, Stefan Wahren wrote:
> Hi,
>=20
> i'm trying to port a ethernet over spi driver to current mainline, which=
=20
> originally based on kernel 2.6.
>=20
> Now i'm searching for some guidelines, checklists, common pitfalls or=20
> just hints about that.
>=20
> Is there something about that, which is up to date?

I don't think there is.

> Is there a list or something of legacy function, which shouldn't be used=
=20
> anymore?

No but the compiler should tell you about functions that were removed!

> Are there any new must have features?

You don't say which 2.6.y version you started with, but API changes I
can think of that come up when backporting are:

- 2.6.24: NAPI now involves a napi_struct rather than fields in
net_device
- 2.6.29: net device operation pointers moved into struct net_device_ops
- 2.6.29: GRO added (can be useful if you have RX checksum offload)
- 2.6.36: ndo_get_stats64 added as alternative to ndo_get_stats
- 2.6.37: vlan_hwaccel_* functions removed; the driver must attach the
tag and call the regular receive function
- 2.6.39: ethtool feature setting replaced by net device operations
ndo_fix_features & ndo_set_features
- 3.2: ndo_set_multicast_list and ndo_set_rx_mode operations merged
- 3.10: VLAN functions and feature flags changed to allow for both
802.1q and 802.1ad tags

Most of the interesting new features are related to multiqueue and
protocol offloads that I wouldn't expect to exist in an SPI-attached
Ethernet controller.  There are a few other things you can now expose if
the hardware supports it:

- MDI(-X) status and control (through ethtool)
- EEE status and control (through ethtool)
- Feature flags to disable Ethernet FCS insertion, validation and
stripping

> Is there a good reference implementation for ethernet over spi?

Don't know.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-PaswF9fuO3itSyoUxu1r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1XSUOe/yOyVhhEJAQpD3A/+KQrFfy86HYq+bP/3TeQI0H7mJRdicHHM
tmH3qVC5VF5zOwjB8szcrEo/NYJhPXeFzNsoNHUMk4aTZut+4x9R62tJYym2cw4Z
AYlfGQo5AqBQTD4dYaAQalEgU2ZdzKEnh5DOkeHALYEvvSF+/769UaFVPERvVz6i
gUXOfR48F7bxJBIufzLp4NTmzcV6gA8Vn3YyOl5t0QN2PgzK0PzZE0PLdvO7+aIk
LH6/n6vk/zlXFMCFakZQbwX6sVC+WQrVBUX+SIim1iry0/8zrKJqW39p8pA0q/g2
jeXgLkST2JnzLmgekCOmVXQg3rXPHgDFOQMl5FzVt0UC1OY548e58bQkWX6F+7OW
daru21yWyQR091aISz6fZY2GejBXkFjteIaOjwrrvGmIx2fkgU6Yky/EgugohlF+
TMMvp8HVrddpZb6f2vBzRMOIOLDBHx8nYJygJyzZGwHR5U7qhw9q8ksKBWwtDBwv
iOqEHp3ADDrLmEogPXz4Q70ORK4CC1IUY7wH2fuR39P1yVDDyR8rqX5Usz1usHw7
ebyVbBFxjiOXVrHgImIMLyypjrQfkJ5FjCifteEzZxu68yKKw19zUm7qBlBHfvUM
B/EiAGitbwc2ryK/bHAcPl2heHraRp1/TAUV5ZzqPvrjNYR07tlHSwKktsD+zyBX
mxjYoUtUZU0=
=wneJ
-----END PGP SIGNATURE-----

--=-PaswF9fuO3itSyoUxu1r--
