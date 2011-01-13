From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] etherdevice.h: Add is_unicast_ether_addr
 function
Date: Thu, 13 Jan 2011 09:55:16 +0100
Message-ID: <1294908916.3570.21.camel@edumazet-laptop>
References: <20110112.234250.10542369.davem@davemloft.net>
	 <1294906496-14950-1-git-send-email-tklauser@distanz.ch>
	 <1294907081.4114.35.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tobias Klauser <tklauser@distanz.ch>,
	David Miller <davem@davemloft.net>, cmetcalf@tilera.com,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:58892 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090Ab1AMIzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 03:55:22 -0500
Received: by wwi17 with SMTP id 17so4833336wwi.1
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 00:55:21 -0800 (PST)
In-Reply-To: <1294907081.4114.35.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 00:24 -0800, Joe Perches a =C3=A9crit :
> On Thu, 2011-01-13 at 09:14 +0100, Tobias Klauser wrote:
> > >From a check for !is_multicast_ether_addr it is not always obvious=
 that
> > we're checking for a unicast address. So add this helper function t=
o
> > make those code paths easier to read.
> >  include/linux/etherdevice.h |   11 +++++++++++
> []
> >  /**
> > + * is_unicast_ether_addr - Determine if the Ethernet address is un=
icast
> > + * @addr: Pointer to a six-byte array containing the Ethernet addr=
ess
> > + *
> > + * Return true if the address is a unicast address.
> > + */
> > +static inline int is_unicast_ether_addr(const u8 *addr)
> > +{
> > +	return !is_multicast_ether_addr(addr);
> > +}
>=20
> Can't you simply use is_valid_ether_addr?
>=20
> I can't think of much reason that a new function for
> !multicast without the !is_zero is needed.
>=20

performance ?

is_valid_ether_addr() is used at device init time, not when receiving
packets.

I am not sure we _need_ to check for is_zero_ether_addr() each time we
receive a packet.

Either a MAC is unicast or multicast.

A zero address is not multicast for sure.



