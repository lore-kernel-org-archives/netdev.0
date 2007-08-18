From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] restore netdev_priv optimization (planb)
Date: Fri, 17 Aug 2007 18:28:07 -0700
Message-ID: <20070817182807.7591878d@freepuppy.rosehill.hemminger.net>
References: <20070817161928.6b6302fd@freepuppy.rosehill.hemminger.net>
	<20070817.165625.23014105.davem@davemloft.net>
	<20070817174909.5e890ad6@freepuppy.rosehill.hemminger.net>
	<20070817.180006.98552435.davem@davemloft.net>
	<46C64995.4030401@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39326 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751590AbXHRB23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:28:29 -0400
In-Reply-To: <46C64995.4030401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Aug 2007 18:21:25 -0700
"Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> David Miller wrote:
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date: Fri, 17 Aug 2007 17:49:09 -0700
> > 
> >> Fix optimization of netdev_priv() lost by the addition of multiqueue.
> >>
> >> Only configurations that define MULITQUEUE need the extra overhead in
> >> netdevice structure and the loss of the netdev_priv optimization.
> >>
> >> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> > 
> > Every distribution vendor is going to turn MULTIQUEUE on.  Therefore
> > %99 of Linux users will not see any gain from your patch.
> > 
> > You're walking around in a dark room and hitting walls every
> > few seconds.  Take a moment and think about how to really deal
> > with this generically for a second before churning out another
> > patch.
> > 
> > For example, how about making the multiqueue limit fixed, say at 64
> > queues, and declare the egress_queues as an array of 64 entries.  Then
> > you can get constant pointer formation for both the netdev priv and
> > the queues.
> 
> this sounds highly optimistic ("64 queues is enough for everyone"?) and probably 
> will be quickly outdated by both hardware and demand...
> 

Plan C was replacing MULTIQUEUE boolean with a int value 1 ... 256.
All this was a one day "what if" exercise, not really a big churn..

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
