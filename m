From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Wed, 8 Jan 2014 00:17:37 +0100
Message-ID: <20140107231737.GM30393@order.stressinduktion.org>
References: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com> <20140107175507.fb543c70.billfink@mindspring.com> <20140107230134.GK30393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Bill Fink <billfink@mindspring.com>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46603 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727AbaAGXRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:17:38 -0500
Content-Disposition: inline
In-Reply-To: <20140107230134.GK30393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 12:01:34AM +0100, Hannes Frederic Sowa wrote:
> On Tue, Jan 07, 2014 at 05:55:07PM -0500, Bill Fink wrote:
> > On Tue,  7 Jan 2014, Francois-Xavier Le Bail wrote:
> > 
> > > This change allows to follow a recommandation of RFC4942.
> > > 
> > > - Add "anycast_src_echo_reply" sysctl to control the use of anycast addresses
> > >   as source addresses for ICMPv6 echo reply. This sysctl is false by default
> > >   to preserve existing behavior.
> > > - Add inline check ipv6_anycast_destination().
> > > - Use them in icmpv6_echo_reply().
> > > 
> > > Reference:
> > > RFC4942 - IPv6 Transition/Coexistence Security Considerations
> > >    (http://tools.ietf.org/html/rfc4942#section-2.1.6)
> > > 
> > > 2.1.6. Anycast Traffic Identification and Security
> > > 
> > >    [...]
> > >    To avoid exposing knowledge about the internal structure of the
> > >    network, it is recommended that anycast servers now take advantage of
> > >    the ability to return responses with the anycast address as the
> > >    source address if possible.
> > > 
> > > Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> > > ---
> > > v4: update Subject and Documentation, this work also with anycast addresses
> > >     created via API, not just with Subnet-Router anycast addresses.
> > > 
> > > v5: alternative way, replace ipv6_chk_acast_addr() test by
> > >     ipv6_anycast_destination() test.
> > 
> > Why is ICMPV6 Echo Reply special?  Can't the internal structure
> > of the network be divined from other ICMPv6 responses such as
> > Destination Unreachable, Time Exceeded (Hop Limit), and Parameter
> > Problem.
> 
> No, here destination must match the source address so that the other side
> handles accordingly when the icmp error is pushed up to the socket layer.

I forgot to mention, rest of kernel followes the old RFC advise to never
use anycast addresses as source addresses.

I guess this will be weakend with upcoming patches so in future this
depends on socket settings and other tweaks. If that's the case default will
be to also respond with anycast source if original destination was anycast.

Greetings,

  Hannes
