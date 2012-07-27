From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for
 loadbalancing too?
Date: Fri, 27 Jul 2012 13:13:26 -0400
Message-ID: <20120727171326.GC7323@quad.redhat.com>
References: <500EC5CF.3080400@genband.com>
 <20120724164220.GA1721@minipsycho.orion>
 <21683.1343153629@death.nxdomain>
 <500F032D.3070104@genband.com>
 <24104.1343162975@death.nxdomain>
 <500F15C3.4090906@genband.com>
 <20120727145514.GB7323@quad.redhat.com>
 <5012BEB1.9030306@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <gospo@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>, andy@greyhouse.net
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208Ab2G0ROX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 13:14:23 -0400
Content-Disposition: inline
In-Reply-To: <5012BEB1.9030306@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 27, 2012 at 10:15:45AM -0600, Chris Friesen wrote:
> On 07/27/2012 08:55 AM, Andy Gospodarek wrote:
> >On Tue, Jul 24, 2012 at 03:38:11PM -0600, Chris Friesen wrote:
> 
> >>In our environment (ATCA shelf) the switches have been customized to
> >>handle some of this stuff so arpmon does work reliably with xor.
> >Good.
> >
> >>In the general case it sounds like the "PF bonding ignores packets
> >>from VFs" is a better bet then.
> >It really might be.  There are some registers in the 82599 datasheets
> >that are not used by the ixgbe driver, but might help you in this area.
> >
> >If you take a look at PFVML2FLT and PFUTA and their current status on
> >your system you might be able to put something together that gives you
> >what you want.
> 
> I think it's simpler than that.  By my reading of the 82599
> datasheet, the LB bit in the status field of the rx descriptor will
> indicate if the packet came from a VM.
> 
Ah, you are correct.  I'm curious if this bit is also set on VF<->VF
traffic.

> >It would likely mean you have to run a custom ixgbe-driver, but that
> >doesn't sound like much of an issue.
> 
> 
> While I'd like to avoid it if possible, we've already had to tweak
> the driver for other things.
As long as driver resets are not needed for some of these changes to
take effect, there is a chance you can write some of these bits from a
userspace program.  I haven't done it myself, but I should try it.  That
might allow you to run a stock driver from a distro and still get what
you want.  

> The complication is that we've got a few different types of hardware
> and they're not all running 82599.  I'm trying to figure out if the
> other hardware can do something similar.
That would indicate that this would be something that the stack as well
as some of the stacked modules bonding, vlans, bridges, etc. may need to
have some special code to handle.  I'm not sure I'm a big fan right now,
but I'll hold off judgement until we see how this shakes out.
