From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Wed, 15 Jan 2014 01:31:17 +0000
Message-ID: <1389749477.3720.173.camel@deadeye.wl.decadent.org.uk>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	 <20140113.115913.1269834557058575064.davem@davemloft.net>
	 <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389646213.2025.159.camel@bwh-desktop.uk.level5networks.com>
	 <1389649061.31367.236.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EDcXPenmTMKS3QZyQS7C"
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45493 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751068AbaAOBbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:31:24 -0500
In-Reply-To: <1389649061.31367.236.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EDcXPenmTMKS3QZyQS7C
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-13 at 13:37 -0800, Eric Dumazet wrote:
> On Mon, 2014-01-13 at 20:50 +0000, Ben Hutchings wrote:
>=20
> > According to the original report of that vulnerability:
> >=20
> > > skb_flow_dissect() were used by several places:                      =
  =20
> > > - packet scheduler that want classify flows                          =
  =20
> > > - skb_get_rxhash() that will be used by RPS, vxlan, multiqueue       =
  =20
> > > tap,macvtap packet fanout                                            =
  =20
> > > - skb_probe_transport_header() which was used for probing transport  =
  =20
> > > header for DODGY packets                                             =
  =20
> > > - __skb_get_poff() which will be used by socket filter            =
=20
> >=20
> > So flow dissector is already part of the attack surface for both local
> > and remote users in common configurations.
>=20
> Take a debian or Android distro, and this bug is not hit on 'common
> configurations'. Send them a 'packet of death', they will not hang,
> unless some admin set up RPS/RFS on the incoming device.
[...]

When I investigated the scope of this for Debian, I tried sending a
'packet of death' to a VM and actually triggered the lockup in the TX
path of the *host*, running Debian unstable with Linux 3.11.  I didn't
track down exactly why that was but I think that libvirt's default
networking configuration includes multiqueue devices that use flow
dissector.

Ben.

--=20
Ben Hutchings
Life is what happens to you while you're busy making other plans.
                                                               - John Lenno=
n

--=-EDcXPenmTMKS3QZyQS7C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtXk5ee/yOyVhhEJAQrcvRAAinV9ndcV5XIaI0BznRjbYbJzXXfxyl5+
SCskObU2w2i2G+5pMowhx772Qs6P3MMGSXbfTUrXANC391nZxhf5q26bE522JYfp
rL0De76ghu3d5LcmNm+lpXrF69SGvyEIq56VBaAogA3SVA1cYldp0YckUM3qDERD
L4GGBLQzl+9cM5q4zPd5OQ+EpfQrrTrXiVFa0jGGe2CowlVOFyFq6spqvULqZTZ1
4bSqAQy1IEzxNuFQzse+f1ynUxpGA7DRYMo3XMTumHwacJWBBO5Fwm54HZhCmQPo
raTYuHPwPKJwKfeSJzLaQoEcCbOW0JEJHU0QwloULfvjY/4JY1m8Bh4C8cSxcMXX
C+TQl5TPvok/5IXZHSmqAz7On5/qJt/XAPwXSFUT3tZCYAM0nTcsMFhPTcxGjxdV
5OcvNJxzoBFBXFwqUrrkm7SCmVkZL2H6PXIk9ZXgffR8Rk56Iv7eabPHV39/hSOj
X82t268poh+/xTQM+16SnzcjUYQByP8nNFYDs0HJMBDLJCpL1Cs8G017mkZPXMpn
lJpGfAXr6UUCZGtgolA6TLEsI2PLBun0moxncuoRPB5xJa8ynHjDBaTkKiFXV2Eu
49JV48zV1w8hh443zlpxSWLZmGYN/MnIzeaaMWTNGrM6UE2ZvzAsOQV31YTYgLAh
BcGz1hBgJM0=
=jtHs
-----END PGP SIGNATURE-----

--=-EDcXPenmTMKS3QZyQS7C--
