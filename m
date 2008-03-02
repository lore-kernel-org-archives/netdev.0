From: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Subject: Re: [PATCH 2/2] [IPV6]: Fix source address selection for ORCHID
	addresses
Date: Sun, 2 Mar 2008 23:59:54 +0200
Message-ID: <20080302215954.GS5813@verkkotelakka.net>
References: <20080221100842.GA24905@verkkotelakka.net> <20080302.213902.68664760.yoshfuji@linux-ipv6.org> <20080302165453.GP32279@verkkotelakka.net> <20080303.030239.105475439.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="b2ktwntdbf0dPnbx"
Cc: netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from refraktori.verkkotelakka.net ([79.171.233.68]:59474 "EHLO
	refraktori.verkkotelakka.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750735AbYCBV75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 16:59:57 -0500
Content-Disposition: inline
In-Reply-To: <20080303.030239.105475439.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--b2ktwntdbf0dPnbx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 03, 2008 at 03:02:39AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ w=
rote:
> In article <20080302165453.GP32279@verkkotelakka.net> (at Sun, 2 Mar 2008=
 18:54:53 +0200), Juha-Matti Tapio <jmtapio@verkkotelakka.net> says:
> > $ ip -6 route
> > 2001:1c:ed0f:6dda:e9c3:8921:2ee7:7a52 dev dummy0  metric 1024  expires =
8567991sec mtu 1500 advmss 1440 hoplimit 4294967295
> > [...]
> > 2002:4fab:e944:1100::/64 dev eth0  metric 256  expires 8211503sec mtu 1=
500 advmss 1440 hoplimit 4294967295
> > [...]
> > default via fe80::1 dev tun0  metric 512  expires 8211512sec mtu 1500 a=
dvmss 1440 hoplimit 4294967295
> > [...]
> >=20
> > In this case if I try to connect to www.ripe.net alias
> > 2001:610:240:11::c100:1319, there is no local source address that
> > matches the destination's label and the outgoing interface does not
> > have any public addresses. Therefore the 8th rule applies and the HIT
> > (2001:...) wins and the destination can not understand the source
> > address.
> > I'm not particularly happy with the above mentioned second patch, but
> > I could not come up with a more elegant fix.
> And then, what address should you use? 6to4 address?

Yes, 6to4 is in this scenario the only address that is globally
reachable from normal systems.

> Then, what you should do is to appropriately configure your policy
> (label) table via the addrlabel subsystem.

That would propably mean doing something like merging labels 1 (::/0),
2 (6to4) and 6 (Teredo) together? I suppose that could be possible,
since after all there is also the workaround of just getting separate
6to4 addresses for all the necessary interfaces. Those solutions feel
a bit awkward and I think they would need to be documented somewhere,
or alternatively the default table should be automatically adjusted
for the problematic scenarios (I fear that it would be messy).

> Or, if ORCHID address can never communicate with non-ORCHID
> address, we could have it in the rule 0 (not 8 minus).

I can think of ORCHID->ORCHID and non-ORCHID->ORCHID communications
but ORCHID->non-ORCHID does not feel useful, at least not with source
address selection. The RFC does not forbid it but at least with HIP it
does not make sense in my opinion. If the destination has ORCHID
capability, it can be identified by an ORCHID address instead of a
regular address, or the connection could be upgraded with something
like opportunistic HIP. If the destination does not have ORCHID
support, the connection pretty much fails.=20

Moving the check to rule 0 would be ok by me. I personally prefer this
option. Configuring the labels manually requires quite a lot of
knowledge about addresses from the admin.


--b2ktwntdbf0dPnbx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHyyNaRGhQc/k/gTsRAsAmAJwK5+TTaL/NlofiK4QhkgtP1IxnOgCgi2Ld
SpklLlv6Z1q9131j7mbjj4Y=
=zHly
-----END PGP SIGNATURE-----

--b2ktwntdbf0dPnbx--
