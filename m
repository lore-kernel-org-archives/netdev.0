From: Bill Fink <billfink@mindspring.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 03:23:57 -0400
Message-ID: <20060525032357.4990425f.billfink@mindspring.com>
References: <20060523.182217.59656237.davem@davemloft.net>
	<4474AE92.3030501@garzik.org>
	<20060524191442.GG22881@ipom.com>
	<200605241501.53477.bcook@bpointsys.com>
	<4474BD52.6020604@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcook@bpointsys.com, phil@ipom.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpauth04.mail.atl.earthlink.net ([209.86.89.64]:58562 "EHLO
	smtpauth04.mail.atl.earthlink.net") by vger.kernel.org with ESMTP
	id S965067AbWEYHYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 03:24:08 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4474BD52.6020604@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 May 2006, Jeff Garzik wrote:

> Brent Cook wrote:
> > Note that this is just clearing the hardware statistics on the interface, and 
> > would not require any kind of atomic_increment addition for interfaces that 
> > support that. It would be kind-of awkward to implement this on drivers that  
> > increment stats in hardware though (lo, vlan, br, etc.) This also brings up 
> > the question of resetting the stats for 'netstat -s'
> 
> If you don't atomically clear the statistics, then you are leaving open 
> a window where the stats could easily be corrupted, if the network 
> interface is under load.
> 
> This 'clearing' operation has implications on the rest of the statistics 
> usage.
> 
> More complexity, and breaking of apps, when we could just use the 
> existing, working system?  I'll take the "do nothing, break nothing, 
> everything still works" route any day.

I'll admit to not knowing all the intricacies of the kernel coding involved,
but I don't offhand see how zeroing the stats would be significantly more
complex than updating the stats during normal usage.  But I'll have to
leave that argument to the experts.

To me the main argument is that such a stat zeroing feature would be
extremely useful.  When trying to track down nasty networking problems
that traverse a multitude of devices, it is often highly desirable to
zero the interface statistics on all the interfaces in the path (which
is available on all networking switches and routers I have worked with),
run some kind of stress test across the path, and then examine the packet
and error counters on all the involved interfaces.  This makes it easy to
pinpoint where packets are getting lost or errors are being introduced,
especially when there are scores of stats per device and you may not even
know a priori exactly what you are looking for.  Using such a scheme, the
human mind can quickly discern patterns in the data and focus in on any
likely problem areas.  The human mind (at least speaking for myself) is
not nearly as adept when having to deal with deltas.  Yes, you can record
the initial state of all the devices, run the stress test, record the new
state of all the devices, and then spend a large amount of time devising
a script to calculate all the deltas for all the scores of variables on
all the involved devices, and then finally try and figure out what is
wrong.  But it would be so much better, easier, and more efficient, if
the kernel simply provided such a feature that almost all other networking
devices provide.

I also think the SNMP/mgt apps argument is specious.  A) SNMP isn't even
an issue with all networks.  B) As has been pointed out by others, there
is no requirement to have to use such a new stats zeroing feature.  It
would simply be a tool in the network engineer's toolbelt, just like
possibly taking an interface down and back up to see if it corrects a
problem.  The network engineer has to balance the potential benefit/harm
of any action he chooses to take, but let him have that choice.  And C)
I don't think any decent SNMP/mgt app will be particularly bothered by
zeroing interface stats.  I believe they are fairly decent about dealing
with such events (I don't recall our MRTG graphs getting any giant spikes
when I've zeroed interface stats on our GigE/10-GigE switches).  I think
the main harm in such a case would be the loss of a sampling interval.

						-Bill
