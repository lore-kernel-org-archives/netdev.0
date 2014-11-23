From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to real
 device.
Date: Sun, 23 Nov 2014 03:15:12 +0000
Message-ID: <1416712512.7215.34.camel@decadent.org.uk>
References: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Lt0oOJpIJNDyFDjRISg4"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45416 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751189AbaKWDP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 22:15:27 -0500
In-Reply-To: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Lt0oOJpIJNDyFDjRISg4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-21 at 14:16 +0100, Richard Cochran wrote:
> Commit a6111d3c "vlan: Pass SIOC[SG]HWTSTAMP ioctls to real device"
> intended to enable hardware time stamping on VLAN interfaces, but
> passing SIOCSHWTSTAMP is only half of the story. This patch adds
> the second half, by letting user space find out the time stamping
> capabilities of the device backing a VLAN interface.
[...]

This assumes that the same PTP capabilities apply to VLAN-tagged frames.
I don't think it's at all safe to assume that RX filter modes other than
HWTSTAMP_FILTER_ALL will include VLAN-tagged frames.  I think it is
necessary to define additional modes that explicitly include VLAN-tagged
frames.

I also disagree in general that reconfiguring a VLAN device should make
changes to the underlying device that affect more than just that VLAN,
i.e. SIOCSHWTSTAMP should not be passed through.  SIOCGHWTSTAMP could be
passed through, but rx_filter would need adjustment (VLAN-tagged modes
on the underlying devices become untagged modes on the VLAN device).

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-Lt0oOJpIJNDyFDjRISg4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHFRRee/yOyVhhEJAQqjsw//Ws4C+RmJCCPrd894tgI3KnlJxL1qITxe
vdAFAD2xMLvat4c06bwD3FVe17xvNDPVr/llkF9ea/5dVUEQNtXG0uY83xya3LAD
V03FxZnRXYozRSvob1PhhYAowR6h32xUpJ2IKIuhXLvQZIqBn5gnFgJJNhm9/pAf
I37h6cm/nvyrFDMNRv63LwsnBrduzr0gNkMta2caKQxoznVTGnfVI0y9A1V0qt/B
vTBw9dtdWEO5/vCR5nwktjQF26kxUvH4PhMkWKCP8SGO2+fcYg0Ih6A6TSXHiLHa
kQEnRMe7grUXce/sVt5q+Qadfjgru+x5HsT3acN/XEfLUQ9zNI+e+IeMOERqNHmw
xK1zGdXEsB9qJAYafFKWnSUHY+cX1HxE/q8u4WFzG69SgiLN4zQQdpjtyxzg60Xm
TnW/0V5x2jkE5C8T03OqNjL6llTUCKAqbS0lfsIRtVulIvAhT/vAHGY1jBQmF9+a
MeaD70NWLem8oG5+SsMta7/fHfVMEHJFHTEKR+ZNq1w5xzdu+st3rFEgHrZK0BmX
pn3Uvbab89SD7xYJQlVuZ467dmP06BY/ULfcGZOgqUFGU8FHma0xE5SlKw4oDhaF
AZv+TfD5nCZoB+JvKccjHOqGzyRK7OU1o4jO/bMoEh7hCeSlNxLBdlGktxWDCIUI
t9Zko9xZ/d8=
=XfT/
-----END PGP SIGNATURE-----

--=-Lt0oOJpIJNDyFDjRISg4--
