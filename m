From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ipv4 regression in 2.6.31 ?
Date: Wed, 16 Sep 2009 10:00:28 -0700
Message-ID: <20090916100028.654f7893@nehalam>
References: <20090914093128.4d709ff6@nehalam>
	<20090915081354.GA10037@ff.dom.local>
	<20090915155719.22bae41e@nehalam>
	<20090916052304.GA4894@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephan von Krawczynski <skraw@ithnet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49443 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753283AbZIPRAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 13:00:31 -0400
In-Reply-To: <20090916052304.GA4894@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Sep 2009 05:23:04 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Tue, Sep 15, 2009 at 03:57:19PM -0700, Stephen Hemminger wrote:
> > On Tue, 15 Sep 2009 08:13:55 +0000
> > Jarek Poplawski <jarkao2@gmail.com> wrote:
> > 
> > > On 14-09-2009 18:31, Stephen Hemminger wrote:
> > > > On Mon, 14 Sep 2009 17:55:05 +0200
> > > > Stephan von Krawczynski <skraw@ithnet.com> wrote:
> > > > 
> > > >> On Mon, 14 Sep 2009 15:57:03 +0200
> > > >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > >>
> > > >>> Stephan von Krawczynski a A~(c)crit :
> > > >>>> Hello all,
> > > ...
> > > >>> rp_filter - INTEGER
> > > >>>         0 - No source validation.
> > > >>>         1 - Strict mode as defined in RFC3704 Strict Reverse Path
> > > >>>             Each incoming packet is tested against the FIB and if the interface
> > > >>>             is not the best reverse path the packet check will fail.
> > > >>>             By default failed packets are discarded.
> > > >>>         2 - Loose mode as defined in RFC3704 Loose Reverse Path
> > > >>>             Each incoming packet's source address is also tested against the FIB
> > > >>>             and if the source address is not reachable via any interface
> > > >>>             the packet check will fail.
> > > ...
> > > > RP filter did not work correctly in 2.6.30. The code added to to the loose
> > > > mode caused a bug; the rp_filter value was being computed as:
> > > >   rp_filter = interface_value & all_value;
> > > > So in order to get reverse path filter both would have to be set.
> > > > 
> > > > In 2.6.31 this was change to:
> > > >    rp_filter = max(interface_value, all_value);
> > > > 
> > > > This was the intended behaviour, if user asks all interfaces to have rp
> > > > filtering turned on, then set /proc/sys/net/ipv4/conf/all/rp_filter = 1
> > > > or to turn on just one interface, set it for just that interface.
> > > 
> > > Alas this max() formula handles also cases where both values are set
> > > and it doesn't look very natural/"user friendly" to me. Especially
> > > with something like this: all_value = 2; interface_value = 1
> > > Why would anybody care to bother with interface_value in such a case?
> > > 
> > > "All" suggests "default" in this context, so I'd rather expect
> > > something like:
> > >     rp_filter = interface_value ? : all_value;
> > > which gives "the inteded behaviour" too, plus more...
> > > 
> > > We'd only need to add e.g.:
> > >  0 - Default ("all") validation. (No source validation if "all" is 0).
> > >  3 - No source validation on this interface.
> > 
> > More values == more confusion.
> > I chose the maxconf() method to make rp_filter consistent with other
> > multi valued variables (arp_announce and arp_ignore).
> 
> This additional value is not necessary (it'd give as superpowers).
> Max seems logical to me only when values are sorted (especially if
> max is the strictest).

The values had to be unsorted because of the requirement to retain
interface compatibility with older releases.
-- 
