From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4 routing: multipath with cache support,
 2.6.10-rc3
Date: Wed, 9 Feb 2005 12:01:57 -0800
Message-ID: <20050209120157.18dc75c1.davem@davemloft.net>
References: <41C6B54F.2020604@einar-lueck.de>
	<20050202172333.4d0ad5f0.davem@davemloft.net>
	<420A1011.1030602@einar-lueck.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Einar =?ISO-8859-1?Q?L=FCck?= <lkml@einar-lueck.de>
In-Reply-To: <420A1011.1030602@einar-lueck.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 Feb 2005 14:28:49 +0100
Einar L=FCck <lkml@einar-lueck.de> wrote:

> The scenarios we have in mind are setups in which a set of collaborat=
ing=20
> servers steadly establish connections among each other with a very hi=
gh rate.=20
> This high rate requirement drove us to consider the inclusion of all=20
> alternative routes into the routing cache because the corresponding d=
elay=20
> for each connection establishment is low and the load is balanced ove=
r all
> available routes. That's why we did not consider a slow lookup in the=
 fib=20
> for each connection established.

So essentially you want per-flow multipathing.  Except that you're impl=
ementation
is over-optimizing it to the point where it's only per-flow for your sp=
ecific
case where the connections are short lived and high rate.

This hurts long lasting connections.

So I'm pretty much against this change.  Do it right by making it occur
per-connection attempt, it's not my problem to figure out how to do tha=
t
efficiently, it's your's :-)
