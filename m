From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Wed, 21 Dec 2011 09:56:16 +0100
Message-ID: <20111221085616.GO6348@secunet.com>
References: <4EF030D5.6040603@iki.fi>
 <20111220.020355.942849877817117461.davem@davemloft.net>
 <20111220071843.GL6348@secunet.com>
 <20111220.133542.2144336048061483258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48353 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab1LUI4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 03:56:19 -0500
Content-Disposition: inline
In-Reply-To: <20111220.133542.2144336048061483258.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2011 at 01:35:42PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Tue, 20 Dec 2011 08:18:43 +0100
>=20
> > On Tue, Dec 20, 2011 at 02:03:55AM -0500, David Miller wrote:
> >> From: Timo Ter=E4s <timo.teras@iki.fi>
> >> Date: Tue, 20 Dec 2011 08:53:09 +0200
> >>=20
> >> > Or maybe I missed the place where that updated would happen?
> >>=20
> >> It should happen on every routing cache lookup hit just like we
> >> validate the peer for redirect information.
> >=20
> > The problem is that we need to do a route cache lookup to
> > validate the peer informations. This does not happen if
> > somebody adds a new route. I tried already to add a pmtu specific
> > generation id and it appears to not solve the problem. We would
> > still need to overwrite the cached value if we add a route with mtu=
=2E
>=20
> Why?
>=20
> Every use of a routing cache entry does a dst_check() or a routing
> cache lookup.
>=20
> You can check the generation ID in both locations, and if the
> comparison fails then you force the routing cache entry to be killed
> and the caller performs a lookup.  At that time the refreshing of the
> new FIB entry will be realized.

My decscription was a bit missleading, sorry. This seems to be not
even related to pmtu handling. It's just that we don't use the
user configured metrics on the fib entry if we find an inetpeer
with metrics that are not in INETPEER_METRICS_NEW state when we
initialize the routing metrics in rt_init_metrics(). I tried to add
a route with a hoplimit, this has also no effect if the metrics on
the inetpeer are not new.
