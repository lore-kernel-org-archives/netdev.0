From: David Miller <davem@davemloft.net>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Tue, 20 Dec 2011 13:35:42 -0500 (EST)
Message-ID: <20111220.133542.2144336048061483258.davem@davemloft.net>
References: <4EF030D5.6040603@iki.fi>
	<20111220.020355.942849877817117461.davem@davemloft.net>
	<20111220071843.GL6348@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782Ab1LTSf5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 13:35:57 -0500
In-Reply-To: <20111220071843.GL6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 20 Dec 2011 08:18:43 +0100

> On Tue, Dec 20, 2011 at 02:03:55AM -0500, David Miller wrote:
>> From: Timo Ter=E4s <timo.teras@iki.fi>
>> Date: Tue, 20 Dec 2011 08:53:09 +0200
>>=20
>> > Or maybe I missed the place where that updated would happen?
>>=20
>> It should happen on every routing cache lookup hit just like we
>> validate the peer for redirect information.
>=20
> The problem is that we need to do a route cache lookup to
> validate the peer informations. This does not happen if
> somebody adds a new route. I tried already to add a pmtu specific
> generation id and it appears to not solve the problem. We would
> still need to overwrite the cached value if we add a route with mtu.

Why?

Every use of a routing cache entry does a dst_check() or a routing
cache lookup.

You can check the generation ID in both locations, and if the
comparison fails then you force the routing cache entry to be killed
and the caller performs a lookup.  At that time the refreshing of the
new FIB entry will be realized.

The critical bit is invalidating the routing cache entry, I can only
guess that you're not doing that.
