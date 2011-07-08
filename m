From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 12:59:12 -0700 (PDT)
Message-ID: <20110708.125912.1535057393082512441.davem@davemloft.net>
References: <20110708.122742.1006323245708104141.davem@davemloft.net>
	<CAHXqBFKE_hLvFgL1_7F+k+pQ0+tEuhBqeRUOtgaM1yrjvXQQww@mail.gmail.com>
	<20110708.125118.886216418938741383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@purestorage.com, johnwheffner@gmail.com, mj@ucw.cz,
	netdev@vger.kernel.org
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754917Ab1GHT7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 15:59:18 -0400
In-Reply-To: <20110708.125118.886216418938741383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Fri, 08 Jul 2011 12:51:18 -0700 (PDT)

> From: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
> Date: Fri, 8 Jul 2011 21:39:18 +0200
>=20
>> With b[3] =3D b[0] ^ b[1] ^ b[2] you get 2^24 keys that hash to the =
same bucket.
>=20
> Ok, I'm convinced, thanks :-)

Although, actually it's not this simple.  The attack doesn't work.

As they "attack" us, the ARP hash table grows and thus the hash mask
changes to match.  Then his old collisions won't collide any more.

We could even adjust the fold shifts as the table grows to make this
effect even more pronounced.
