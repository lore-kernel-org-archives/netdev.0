From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4 routing: multipath with cache support,
 2.6.10-rc3
Date: Wed, 9 Feb 2005 12:30:04 -0800
Message-ID: <20050209123004.2d65e1cf.davem@davemloft.net>
References: <41C6B54F.2020604@einar-lueck.de>
	<20050202172333.4d0ad5f0.davem@davemloft.net>
	<420A1011.1030602@einar-lueck.de>
	<20050209120157.18dc75c1.davem@davemloft.net>
	<420A715D.7050106@einar-lueck.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Einar =?ISO-8859-1?Q?L=FCck?= <lkml@einar-lueck.de>
In-Reply-To: <420A715D.7050106@einar-lueck.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 09 Feb 2005 21:23:57 +0100
Einar L=FCck <lkml@einar-lueck.de> wrote:

> We do not want per-flow multipathing. We want per connection
> multipathing with fast route lookups (that's why we have all routes in
> the cache). That is exactly what we implemented. Our tests prove that
> a connection keeps its route as long as it lives (the dstentry remains
> associated with the socket). That's why I do not really understand why
> our approach hurts long lasting connections in any way. Can you
> explain your point more precisely?

This was brought up before.  It's the case where the system is acting
as a router, you have to consider that case and not just the one where
the local system is where the connections are originating from.

Your trick only works because of how routes are cached per-socket.
Once you get into the realm of traffic going through the machine as
a router, the trick stops to work.
