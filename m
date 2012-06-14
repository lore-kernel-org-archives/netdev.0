From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Thu, 14 Jun 2012 07:35:29 +0200
Message-ID: <20120614053529.GP27795@secunet.com>
References: <20120613080152.GN27795@secunet.com>
 <20120613.024225.1623724542402950589.davem@davemloft.net>
 <20120613100709.GO27795@secunet.com>
 <20120613.032228.1574539964049471628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45453 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724Ab2FNFfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 01:35:33 -0400
Content-Disposition: inline
In-Reply-To: <20120613.032228.1574539964049471628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 03:22:28AM -0700, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 13 Jun 2012 12:07:09 +0200
> 
> > On Wed, Jun 13, 2012 at 02:42:25AM -0700, David Miller wrote:
> >> From: Steffen Klassert <steffen.klassert@secunet.com>
> >> Date: Wed, 13 Jun 2012 10:01:52 +0200
> >> 
> >> > I think an application that sets IP_PMTUDISC_WANT explicitly will
> >> > rely on the fact that the kernel does pmtu discovery. Changing
> >> > the socket setting to IP_PMTUDISC_DONT the first time we get into
> >> > trouble makes IP_PMTUDISC_WANT pointless for udp and raw sockets.
> >> 
> >> How so?
> >> 
> >> We are mimicking exactly what would happen if we had just created
> >> a new routing cache entry when the application openned the socket.
> >> 
> >> There is no behavioral difference whatsoever.
> >> 
> >> We absolutely do perform PMTU discovery, the first large packet
> >> will trigger it.  And then, as if we had lowered the PMTU in
> >> the routing cache entry, we will stop setting DF in the packets.
> > 
> > Maybe I missunderstood what you meant. I thought that you don't want
> > to update the pmtu cache informations at all on udp and raw.
> > If we update the pmtu cache informations with first large packet,
> > I agree absolutely.
> 
> We don't update the PMTU.
> 
> But we behave as if we did.
> 
> The only effect the IP_PMTUDISC_* values have is in deciding whether
> to set the DF flag in the outgoing packets.

With your patch applied, we stop setting the DF bit after we received
a 'need to frag' ICMP message, but we don't fragment. We send the packets
out unfragmented. Before we removed ip_rt_frag_needed(), we did the
fragmentation according to the pmtu informations we got from the icmp
message. Now the router with the low mtu has to do the fragmentation.
