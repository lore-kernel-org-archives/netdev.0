From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4 routing: multipath with cache support,
 2.6.10-rc3
Date: Wed, 2 Feb 2005 17:23:33 -0800
Message-ID: <20050202172333.4d0ad5f0.davem@davemloft.net>
References: <41C6B54F.2020604@einar-lueck.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Einar =?ISO-8859-1?Q?L=FCck?= <lkml@einar-lueck.de>
In-Reply-To: <41C6B54F.2020604@einar-lueck.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Dec 2004 12:19:43 +0100
Einar L=FCck <lkml@einar-lueck.de> wrote:

> This patch is an approach towards solving some problems with the=20
> current multipath implementation:
> * routing cache allows only one route to be cached for a certain=20
>  search key
> * a mulitpath/load balancing decision is only made in case a=20
>  corresponding route is not yet cached
> In the scenarios, that are relevant to us (high amount of outgoing=20
> connection requests), this is a serious problem.

I agree that per-connection attempt a new multipath decision
should be made, but within a flow I disagree.

This needs to be flow based.

Can you describe more precisely "the scenerios, that are relevant
to us"?

If you are only interested in more precise multipathing when TCP
connections on the local system are made, this we can implement
via a flag to the ipv4 routing cache which forces a new multipath
decision when TCP sockets have their identity established.
We have a precise interface that is invoked at this time, called
ip_route_connect().  So that is where we would pass in some flag
to indicate that we desire the new multipath behavior.

If you want this behavior on a router, you will need to mark the
packets using something like firewall marking on the SKB, then this
mark would be used at route cache lookup time to determine what
kind of multipath decisions to make.

There is no way we can enable the new behavior for every routing
cache lookup.
