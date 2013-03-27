From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Wed, 27 Mar 2013 19:35:58 +0100
Message-ID: <20130327183558.GC23223@order.stressinduktion.org>
References: <1364335457.8215.21.camel@localhost> <20130327151210.GA23223@order.stressinduktion.org> <1364398673.21709.4.camel@localhost> <20130327181146.GB23223@order.stressinduktion.org> <1364408454.15362.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Wilco Baan Hofman <wilco@baanhofman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34577 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554Ab3C0Sf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:35:59 -0400
Content-Disposition: inline
In-Reply-To: <1364408454.15362.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 27, 2013 at 07:20:54PM +0100, Wilco Baan Hofman wrote:
> 
> 
> On Wed, 2013-03-27 at 19:11 +0100, Hannes Frederic Sowa wrote:
> > On Wed, Mar 27, 2013 at 04:37:53PM +0100, Wilco Baan Hofman wrote:
> > > 
> > > Weird, but sure, here goes:
> > > 
> > > ip tunnel add tunv6-uplink1 mode sit remote 192.168.1.1 local
> > > 192.168.1.21
> > > ip link set tunv6-uplink1 up mtu 1472
> > 
> > In my test I didn't specify the local address so addr.s6_addr32[3]
> > seems to be zero.  I'll have to search the RFCs why this is the case.
> 
> See section 3.7, rfc4213:
> 
>    The interface identifier [RFC3513] for such an interface may be based
>    on the 32-bit IPv4 address of an underlying interface, or formed
>    using some other means, as long as it is unique from the other tunnel
>    endpoint with a reasonably high probability.
> 
> http://tools.ietf.org/html/rfc4213

Thanks, I have seen that already. The sit driver is used for more than 6in4
(6to4, isatap, 6rd). So such a change has to be ok with all the other
protocols implemented by sit. I also looked in the historic git archive for a
rationale of this but couldn't find one. Commit messages 2002 where not as
descriptive as today("Import changeset"). :)

I also added YOSHIFUJI Hideaki as Cc, perhaps he knows the reason.
