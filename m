From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6
 tunnels
Date: Fri, 5 Sep 2003 07:31:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905073114.7a9a19e1.davem@redhat.com>
References: <Pine.LNX.4.44.0309031444190.16329-100000@netcore.fi>
	<Pine.LNX.4.44.0309031515500.5039-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0309031515500.5039-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003 19:57:56 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> In MIPL, the MN uses a "default" ::/0 route through the IPv6 tunnel, but
> it is only used for packets using the MN's home address as source. All
> other traffic (including packets already encapsulated by the IPv6 tunnel,
> thus having the care-of address as source) is routed normally through the
> physical device.
> 
> Things like this aren't possible in the current IPv6 routing code, so I
> had to modify the route lookup so it first checks the source address of
> the packet, then the destination.
> 
> I sent a patch for this source address based routing, but it didn't make
> it into the kernel, partly because the USAGI team has plans to introduce
> IPv6 policy routing, which should also fix the problems.

Well, it was rejected for another reason :-)

Doing route selection in the way you propose is completely backwards.

Routing engine is asked only where one would like to go, and in
response we are told how to get there and who to advertise ourselves
as (ie. source address selection).

That is, source address selection is a product of the routing lookup
not an input.

The whole engine works this way.  When TCP connects, unless user has
specified a specific source address when bind()'ing the socket, we
take source address from the route.  Source address selection is
routing task.

I do not see what it is about MIPV6 which changes this.  So you either
have to show me this thing, or accept what I say :-)
