From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: What makes a good fake MAC address?
Date: Wed, 22 Apr 2009 23:13:53 +0200
Message-ID: <49EF8891.9010306@cosmosbay.com>
References: <200904221348.27357.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46741 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbZDVVOA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 17:14:00 -0400
In-Reply-To: <200904221348.27357.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inaky Perez-Gonzalez a =E9crit :
> Hi All
>=20
> The Intel i2400m WiMAX driver behaves as an ethernet device, and curr=
ently=20
> when sending packets to the netdev stack, it fakes an ethernet header=
, sets=20
> the "from" mac address to zeroes and the "to" to it's own MAC address=
=2E
>=20
> The WiMAX network can be considered to be a point-to-point (up to the=
 gateway)=20
> connection, all IP based, so there are not MAC addresses from our gat=
eway=20
> (not to mention that it can change behind us).
>=20
> The problem with using a zero mac address is that it confuses the bri=
dging=20
> software (and maybe others). I was wondering, what would be a fake ma=
c=20
> address we could put in there that is legal for this kind of "faking"=
? [or=20
> the closest thing to legal?]
>=20
> Thanks!
>=20

We have random_ether_addr(), it should be self explained :)

/**
 * random_ether_addr - Generate software assigned random Ethernet addre=
ss
 * @addr: Pointer to a six-byte array containing the Ethernet address
 *
 * Generate a random Ethernet address (MAC) that is not multicast
 * and has the local assigned bit set.
 */
static inline void random_ether_addr(u8 *addr)
{
        get_random_bytes (addr, ETH_ALEN);
        addr [0] &=3D 0xfe;       /* clear multicast bit */
        addr [0] |=3D 0x02;       /* set local assignment bit (IEEE802)=
 */
}




