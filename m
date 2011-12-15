From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Thu, 15 Dec 2011 14:49:58 +0100
Message-ID: <20111215134957.GI6348@secunet.com>
References: <4EE8C6A8.3060308@iki.fi>
 <20111214.125010.82857701285437834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60139 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758795Ab1LONuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 08:50:08 -0500
Content-Disposition: inline
In-Reply-To: <20111214.125010.82857701285437834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2011 at 12:50:10PM -0500, David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Wed, 14 Dec 2011 17:54:16 +0200
>=20
> > So something is does not get updated here. This used to work though=
=2E
> > The current production boxes where I know this work is 2.6.38.8.
>=20
> We store the PMTU externally in inetpeer entries, Eric Dumazet
> fixed recently but that fix hasn't been submitted to -stable
> yet.
>=20

I think we still have at least two problems with pmtu handling.
One is that "ip route flush cache" flushes the routing cache
but not the cached metrics on the inetpeer.

Another problem might be that we ignore the user configured
fib_metrics in rt_init_metrics() if we have a cached metric
on the inetpeer.

I'll try to look at this a bit closer tomorrow.
