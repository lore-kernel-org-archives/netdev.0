From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] bonding: rejoin multicast groups on VLANs
Date: Wed, 29 Sep 2010 17:38:43 -0300
Message-ID: <20100929203843.GD2864@redhat.com>
References: <1285744344-1231-1-git-send-email-fleitner@redhat.com>
 <20100929184413.GY7497@gospo.rdu.redhat.com>
 <20100929193539.GC2864@redhat.com>
 <20100929195411.GZ7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600Ab0I2Uir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 16:38:47 -0400
Content-Disposition: inline
In-Reply-To: <20100929195411.GZ7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 29, 2010 at 03:54:11PM -0400, Andy Gospodarek wrote:
> On Wed, Sep 29, 2010 at 04:35:39PM -0300, Flavio Leitner wrote:
> > On Wed, Sep 29, 2010 at 02:44:13PM -0400, Andy Gospodarek wrote:
> > > On Wed, Sep 29, 2010 at 04:12:24AM -0300, Flavio Leitner wrote:
> > > > It fixes bonding to rejoin multicast groups added
> > > > to VLAN devices on top of bonding when a failover
> > > > happens.
> > > > 
> > > > The first packet may be discarded, so the timer
> > > > assure that at least 3 Reports are sent.
> > > > 
> > > 
> > > Good find, Flavio.  Clearly the fact that multicast membership is broken
> > > needs to be fixed, but I would rather not see timers used at all.  We
> > > worked hard in the past to eliminate timers for several reasons, so I
> > > would rather see a workqueue used.
> > 
> > I noticed that the code is using workqueues now, just thought a
> > simple thing which may run couple times would fit perfectly with
> > a simple timer.
> > 
> 
> Timers runs in softirq context, so I'd rather not add code that takes
> locks and runs in softirq context.
> 
> > 
> > > I also don't like retransmitting the membership report 3 times when it
> > > may not be needed.  Though many switches can handle it, the cost of
> > > receiving and processing what might be a large list of multicast
> > > addresses every 200ms for 600ms doesn't seem ideal.  It also feels like
> > > a hack. :)
> > 
> > Definitely a parameter is much better, but I wasn't sure about
> > the patch approach so I was expecting a review like this and then
> > do the refinements needed. Better to post early, right? :)
> > 
> > I see your point to change the default to one membership report,
> > but we can't assure during a failover if everything has been
> > received. Also, it isn't supposed to keep failing flooding the
> > network, so I would rather have couple membership reports being
> > send than watch an important multicast application failing.
> > 
> > Perhaps 3 is too much, but one sounds too few to me.
> > 
> > what you think?
> > 
> 
> Adding a tunable parameter allows the administrator to decide how many
> is enough.  I would rather keep the default at one and add the tunable
> parameter (which needs to be added to bond_sysfs.c to be effective).
> 
> I have not heard loud complaints about only sending one since the code
> to send retransmits of membership reports was added a few years ago, so
> I'm inclined to think it is working well for most users (or no one is
> using bonding).
> 
> Maybe it would be best to break this into 2 patches.  One that simply
> fixes the failover code so it works with VLANs (that could be done
> easily today) and another patch that can add the code to send multiple
> retransmits.  Would you be willing to do that?

Sure, I can do it and then start another testing session here.

-- 
Flavio
