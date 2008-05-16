From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Fri, 16 May 2008 12:40:39 -0700 (PDT)
Message-ID: <20080516.124039.253626477.davem@davemloft.net>
References: <200805161201.48835.rusty@rustcorp.com.au>
	<20080515.215823.28841530.davem@davemloft.net>
	<200805162032.48469.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mb@bu3sch.de,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, ron.rindjunsky@intel.com, tomasw@gmail.com,
	ivdoorn@gmail.com, peter.p.waskiewicz.jr@intel.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44767
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750951AbYEPTkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 15:40:45 -0400
In-Reply-To: <200805162032.48469.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 16 May 2008 20:32:48 +1000

> On Friday 16 May 2008 14:58:23 David Miller wrote:
> > In fact, I want to move things more and more towards the driver
> > queueing TX packets internally instead of the networking mid-layer.
> >
> > That will ahve benefits for things like TX multiqueue, we won't
> > need any locking at all, nor have any knowledge about multiple
> > queues at all, if the driver takes care of providing the buffer
> > between what the kernel gives it and what the device can handle
> > at the moment.
> 
> That would be great: then I could shove the packet back on the queue myself 
> and not have to ask you about it.  It's adding a *second* queue inside the 
> driver which feels terribly ugly...

My description describes how I want the mid-layer queue to disappear
entirely.  Queueing would be done by the driver only.

Only the driver knows all of these details about how much space there
is, what packet chopping has to take place and what effects that has
on queue space, multiqueue configurations, how one wants to hash to
multiple queues, how to lock this stuff the most efficiently.

The kernel should just get out of the way and let the driver take care
of everything.

Sure, we can have some standard helpers to deal with the most common
cases.  But anything non-trivial right now is painful because the
mid-layer model tries to be too helpful when it should just get out
of the way.
