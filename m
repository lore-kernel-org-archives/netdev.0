From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3
 buffer overflows triggered by hardware devices
Date: Mon, 24 Mar 2014 21:51:01 +0000
Message-ID: <1395697861.2832.84.camel@deadeye.wl.decadent.org.uk>
References: <CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
	 <20140324.131733.723749970605014851.davem@davemloft.net>
	 <CAKPWWNF982P7PtuoySy6ncU1mCNFm2RBMEDKr3-QKoCKU-6AMw@mail.gmail.com>
	 <20140324.143512.68893694230434555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PVUugHK8z8NAUUWcgKlh"
Cc: alon@privatecore.com, David.Laight@aculab.com,
	netdev@vger.kernel.org, grantgrundler@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44613 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751131AbaCXVvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 17:51:23 -0400
In-Reply-To: <20140324.143512.68893694230434555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PVUugHK8z8NAUUWcgKlh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-24 at 14:35 -0400, David Miller wrote:
> From: Alon Nafta <alon@privatecore.com>
> Date: Mon, 24 Mar 2014 10:35:37 -0700
>=20
> > Moreover, a system can be protected from malicious HW, and in fact
> > doesn't have to trust HW at all (except for the CPU obviously).
>=20
> So should we check to make sure the program counter of the cpu really
> increments to the next instruction every time?
>=20
> There is a limit to everything.
>=20
> The length field of DMA descriptors is absolutely, fully, trusted in
> the vast majority of drivers.

There is a real question as to how much peripherals should be trusted.

We already try to avoid trusting USB devices at all, because many
machines have ports that are accessible to users that shouldn't be fully
trusted.  (Also, users may assume it's just as safe to plug in a 'USB
stick' they were given, as it is to insert a disc or memory card.)  A
bug in the HID subsystem has apparently been exploited in the past for
code injection.

Given that some machines also have easily accessible hotplug PCI(e)
ports (CardBus, ExpressCard, Thunderbolt), and that those can be
distrusted at the hardware level (using an IOMMU), it seems like a
worthwhile goal to distrust them at the software level.  However, as you
hinted, this is a big job since any vulnerable driver that's installed
can be exploited.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-PVUugHK8z8NAUUWcgKlh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzCoxee/yOyVhhEJAQrVPQ//dk3gqa8wbeu2LtivXC8r1xPX+GA0dp3W
RyPTNJUcuIekomCF4ncC3JN86o0PLdwie0ZjXneJe4cV9qnDgC0p/buT+NlgQLUW
vauUd74V5ucfOmxJYL336yPB6lFDyChsHMfepqsrbzvnDWEJmRLKO4P7Ab34htgs
jR5vCE7E2rSkbFKIe5+RPykvjIpBt2MRN6U1oJybExjHZKhgqzcgfxw/hk/rWX8t
WhtHNG1OZBx6kHXym8OXic2kkLx/CePMTbsu1BZHDQh1WfDZEJOfndBbZaE3XzWN
tStYnoRg5wLmv4wUsrfcKb0q7wCXWmK+YVnxzQcrExXmyY0WV1/KcyDchNiqxWYf
Tdu8LDesWAFhY7TW03l3uGjsUAuL4XvYVlIkbm8bcdGsGaUPpgNGd9LNT3g2O/ua
bCYg/3qq4+cMfKxwkIuTbo3I5PtD+ScZJS/NsbDNxkUiIJQrs2PryI67I5YD0ZCM
FzGVQHXHVpcq/jvl+pXpRWQGwIcwpFIj3Oc5YFefH0ruv/unAA08XxIbm3A/yTf4
J51BVPWSWXxw2ALaKg3UtBO4kANYulu7MEyVbpqgdYube8a9kYF3BK9jJpQ4moRg
iSgFPTcU8d545qxsMxVFjrHgs8u3Z+RxbD5aLZje1lVYQWQStHV84Kxd8Cg/pQJg
9lFT9RiX7ec=
=yI6p
-----END PGP SIGNATURE-----

--=-PVUugHK8z8NAUUWcgKlh--
