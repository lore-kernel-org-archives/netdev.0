From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: 2.6.25-rc9: Reported regressions from 2.6.24
Date: Tue, 15 Apr 2008 09:14:13 -0400
Message-ID: <20080415131413.GC26591@gospo.usersys.redhat.com>
References: <RR4Oy_oXY2J.A.b0H.A3lAIB@albercik> <480262E9.4030500@trash.net> <480267C0.6020402@trash.net> <48026AAE.8040500@trash.net> <20080414203111.GB26591@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40759 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752969AbYDONOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:14:38 -0400
Content-Disposition: inline
In-Reply-To: <20080414203111.GB26591@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2008 at 04:31:11PM -0400, Andy Gospodarek wrote:
> On Sun, Apr 13, 2008 at 10:18:54PM +0200, Patrick McHardy wrote:
> > Patrick McHardy wrote:
> > >>>
> > >>>Bug-Entry    : http://bugzilla.kernel.org/show_bug.cgi?id=10323
> > >>>Subject        : panic using bridging on linus kernel 2.6.25-rc6
> > >>>Submitter    : Andy Gospodarek <andy@greyhouse.net>
> > >>>Date        : 2008-03-25 11:40 (20 days old)
> > >>
> > >>This looks like another network-namespace regression.
> > >>icmp_send() does:
> > >>
> > >>       net = rt->u.dst.dev->nd_net;
> > >>
> > >>The bridge netfilter code attaches a fake dst_entry to the
> > >>skb which has dev == NULL when passing it to IPv4 netfilter.
> > >>
> > >>Pavel, do you have a better ideas for fixing this than
> > >>instantiating a dst_entry in br_netfilter.c for every
> > >>device (or at least for every namespace)? 
> > >
> > >The description of the problem was not entirely correct, the
> > >bridge-netfilter dst_entry does have a proper device pointer,
> > >it points to a dummy net_device structure however that doesn't
> > >have a namespace associated with it. This blows up in
> > >__ip_route_output_key.
> > 
> > For now I suggest this fix. Andy, could you please test whether it
> > fixes the problem?
> > 
> > 
> 
> I'm guessing it will.  I've been testing my older kernels today and
> somehow I'm unable to reproduce the original problem, so I need to
> figure out what is different about my config now and before.
> 
> I'll definitely post back when I test this, but I wanted to make sure
> you guys knew I was at least trying it. :)
> 

I just got done testing 159d83363b629c91d020734207c1bc788b96af5a and I
can confirm that is resolves my issue.
