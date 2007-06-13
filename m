From: Bill Fink <billfink@mindspring.com>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Tue, 12 Jun 2007 23:38:14 -0400
Message-ID: <20070612233814.4b04db2f.billfink@mindspring.com>
References: <20070512120739.371ada4f.billfink@mindspring.com>
	<649aecc70705120945q58ae79c9r8ff2dc5557658d1e@mail.gmail.com>
	<20070516024409.53049682.billfink@mindspring.com>
	<20070612.151258.120619253.davem@davemloft.net>
	<20070612171603.47736395@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sangtae.ha@gmail.com,
	rhee@eos.ncsu.edu, rhee@ncsu.edu, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:54700 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753172AbXFMDiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 23:38:23 -0400
In-Reply-To: <20070612171603.47736395@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Jun 2007, Stephen Hemminger wrote:

> On Tue, 12 Jun 2007 15:12:58 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Bill Fink <billfink@mindspring.com>
> > Date: Wed, 16 May 2007 02:44:09 -0400
> > 
> > > [root@lang2 ~]# netstat -s | grep -i retrans
> > >     25446 segments retransmited
> > >     20936 fast retransmits
> > >     4503 retransmits in slow start
> > >     4 sack retransmits failed
> > > 
> > > It then only took 2.14 seconds to transfer 1 GB of data.
> > > 
> > > That's all for now.
> > 
> > Thanks for all of your testing and numbers Bill.
> > 
> > Inhong et al., we have to do something about this, the issue
> > has been known and sitting around for weeks if not months.
> > 
> > How safely can we set the default initial_ssthresh to zero in
> > Cubic and BIC?
> 
> Yes. set it to zero. The module parameter could even go, and just
> leave the route metric as a way to set/remember it.

Actually, after thinking about this some more I had some second
thoughts about the matter.  For my scenario of an uncongested 10-GigE
path an initial_ssthresh=0 is definitely what is desired.

But perhaps on a congested link with lots of connections, the
initial_ssthresh=100 setting might have some benefit.  I don't
have an easy way of testing that so I was hoping Injong or someone
else might do that and report back.  If there was a benefit, perhaps
it would be useful to have a per-route option for setting the
initial_ssthresh.  That would leave the question of what to make
the default.  There was also the mystery of why cubic's slow start
performance was so much worse than bic's.  If a real benefit could
be demonstrated for the congested case, and if bic's slow start
behavior could be grafted onto cubic, then bic's current slow start
performance (with initial_ssthresh=100) might serve as an adequate
compromise between performance and not being overly aggressive for
the default behavior.

OTOH just setting it to zero as a default should also be fine as
that's the standard Reno behavior.  I'm leaning in that direction
personally, but I'm possibly biased because of my environment,
where I'm trying to get maximum performance out of 10-GigE WAN
networks that aren't particularly congested normally.

						-Bill
