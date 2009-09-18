From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: ipv4 regression in 2.6.31 ?
Date: Fri, 18 Sep 2009 10:30:15 +0200
Message-ID: <20090918103015.9e7ee289.skraw@ithnet.com>
References: <20090914093128.4d709ff6@nehalam>
	<20090915081354.GA10037@ff.dom.local>
	<20090915155719.22bae41e@nehalam>
	<20090916052304.GA4894@ff.dom.local>
	<20090916100028.654f7893@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-a02.ithnet.com ([217.64.83.97]:48256 "HELO ithnet.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751506AbZIRInj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 04:43:39 -0400
In-Reply-To: <20090916100028.654f7893@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Sep 2009 10:00:28 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Wed, 16 Sep 2009 05:23:04 +0000
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > On Tue, Sep 15, 2009 at 03:57:19PM -0700, Stephen Hemminger wrote:
> > > On Tue, 15 Sep 2009 08:13:55 +0000
> > > Jarek Poplawski <jarkao2@gmail.com> wrote:
> > > 
> > > > On 14-09-2009 18:31, Stephen Hemminger wrote:
> > > > > On Mon, 14 Sep 2009 17:55:05 +0200
> > > > > Stephan von Krawczynski <skraw@ithnet.com> wrote:
> > > > > 
> > > > >> On Mon, 14 Sep 2009 15:57:03 +0200
> > > > >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > > >>
> > > > >>> Stephan von Krawczynski a A~(c)crit :
> > > > >>>> Hello all,
> > > > ...
> > > > >>> rp_filter - INTEGER
> > > > >>>         0 - No source validation.
> > > > >>>         1 - Strict mode as defined in RFC3704 Strict Reverse Path
> > > > >>>             Each incoming packet is tested against the FIB and if the interface
> > > > >>>             is not the best reverse path the packet check will fail.
> > > > >>>             By default failed packets are discarded.
> > > > >>>         2 - Loose mode as defined in RFC3704 Loose Reverse Path
> > > > >>>             Each incoming packet's source address is also tested against the FIB
> > > > >>>             and if the source address is not reachable via any interface
> > > > >>>             the packet check will fail.
> > > > ...
> > > > > RP filter did not work correctly in 2.6.30. The code added to to the loose
> > > > > mode caused a bug; the rp_filter value was being computed as:
> > > > >   rp_filter = interface_value & all_value;
> > > > > So in order to get reverse path filter both would have to be set.
> > > > > 
> > > > > In 2.6.31 this was change to:
> > > > >    rp_filter = max(interface_value, all_value);
> > > > > 
> > > > > This was the intended behaviour, if user asks all interfaces to have rp
> > > > > filtering turned on, then set /proc/sys/net/ipv4/conf/all/rp_filter = 1
> > > > > or to turn on just one interface, set it for just that interface.
> > > > 
> > > > Alas this max() formula handles also cases where both values are set
> > > > and it doesn't look very natural/"user friendly" to me. Especially
> > > > with something like this: all_value = 2; interface_value = 1
> > > > Why would anybody care to bother with interface_value in such a case?
> > > > 
> > > > "All" suggests "default" in this context, so I'd rather expect
> > > > something like:
> > > >     rp_filter = interface_value ? : all_value;
> > > > which gives "the inteded behaviour" too, plus more...
> > > > 
> > > > We'd only need to add e.g.:
> > > >  0 - Default ("all") validation. (No source validation if "all" is 0).
> > > >  3 - No source validation on this interface.
> > > 
> > > More values == more confusion.
> > > I chose the maxconf() method to make rp_filter consistent with other
> > > multi valued variables (arp_announce and arp_ignore).
> > 
> > This additional value is not necessary (it'd give as superpowers).
> > Max seems logical to me only when values are sorted (especially if
> > max is the strictest).
> 
> The values had to be unsorted because of the requirement to retain
> interface compatibility with older releases.

The parameters are the same (I guess this is what you call interface
compatibility), but the function came out different, meaning you broke
functional compatibility with 2.6.31 instead. Just to mention that - though
the argument is leight-weight for the compatibility broke because the whole
thing was broken somehow before the bugfix.

-- 
Regards,
Stephan

