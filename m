From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: icmp_unreachable uses wrong ip
Date: Wed, 4 May 2005 10:29:51 +0200
Message-ID: <20050504082951.GA13761@xi.wantstofly.org>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <200505030944.49175.hasso@estpak.ee> <4277BFA6.8090306@trash.net> <200505040235.33461.hasso@estpak.ee> <42780B44.8040803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hasso Tepper <hasso@estpak.ee>, "J. Simonetti" <jeroens@office.netland.nl>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42780B44.8040803@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 04, 2005 at 01:37:40AM +0200, Patrick McHardy wrote:

> >>But when multiple addresses are used the result can be even more
> >>confusing. I don't like inconsistent behaviour, and this patch works
> >>sometimes and sometimes it doesn't.
> > 
> > I see no behaviour you can define as "it doesn't work". Purpose of this 
> > patch is to provide info about links (not addresses, you can't have this 
> > info) used to forward packets and it does the job. 
> 
> Well, arguably it can be called "doesn't work" if addresses not used
> at all during transmit of the packet show up in traceroute.

That argument doesn't hold, since exactly the same situation occurs
if we use the outgoing address as we do now.

With asymmetric routing, the incoming interface, interface to
the destination, and the interface back to the source might all
be different, so we can end up with:

       path from r3 back to a
       +-------------------+
       |                   |
       V                   |
       a --- r1 --- r2 --- r3 --- r4 --- r5 --- b

The address of the 'upper' interface of r3 is likewise "not used
at all during transmit of the packet", but it is the address we
currently send the ICMP from.


--L
