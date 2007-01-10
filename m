From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Wed, 10 Jan 2007 10:04:11 +0100
Message-ID: <20070110090411.GA1589@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <459EB627.5040606@candelatech.com> <20070108065346.GA1665@ff.dom.local> <45A277E6.6000904@candelatech.com> <20070108100350.1187a3dc@freekitty> <20070109081045.GA1703@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:58298 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932740AbXAJJCT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 04:02:19 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20070109081045.GA1703@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 09:10:45AM +0100, Jarek Poplawski wrote:
> On Mon, Jan 08, 2007 at 10:03:50AM -0800, Stephen Hemminger wrote:
...
> > > >  * Must be invoked with RCU read lock (no preempt)
> > > >  */
> > > > struct net_device *__find_vlan_dev(struct net_device *real_dev,
> > > > ...
> > > >
> > > > But later in this file no sign of disabling preemption
> > > > for these calls and for hlist_add_head_rcu and hlist_del_rcu.
> > > >
> > > > I can't imagine how this works?
> > 
> > Preempt is already disabled on the receive path.
> 
> I'm not sure you're talking about the same thing -

Hello Stephen,

It looks like you're talking about the right thing
and I'm a fool again! Now I try to find why I even 
had to pay for this. I read again and again adequate
chapters from R. Love and C. Benvenuti's books, see
a lot about kernel preemption in 2.6, but can't see
anything about preemption disabled in ioctls - maybe
I'm blind or they are badly translated. Now I look
into "Linux Device Drivers", see ch. 6 about ioctls,
blocking I/O and RCU, but nothing about preemption
disabled again. Maybe this is omited because it's
obvious to people who started hacking with earlier
kernels?

When I added to this things like: "If the mutex is
not available right now, it will sleep until it can
get it." and "It is illegal to block while in an RCU
read-side critical section." I didn't even try to
think about mutex or malloc with GFP_KERNEL inside
RCU block.
 
I'm enormously grateful you didn't lose patience
in guiding me yet - I hope it'll save this list from
nervous breakdown.

Many thanks and regards as always,

Jarek P.

PS: probably you could profit from this some day 
and write something like "Linux Internals for
Dummies" - it would be simple cut & paste of my
discoveries and your responses!
