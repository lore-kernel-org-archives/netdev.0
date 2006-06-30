From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 10:35:18 -0400
Message-ID: <1151678118.5270.45.camel@jzny2>
References: <20060628130124.GX1376@postel.suug.ch>
	 <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch>
	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>
	 <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch>
	 <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch>
	 <1151675843.5270.18.camel@jzny2>  <20060630141531.GG14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:12977 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932787AbWF3Ofc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 10:35:32 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FwK5k-00026l-IN
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 10:35:32 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630141531.GG14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 16:15 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 09:57
> > On Fri, 2006-30-06 at 15:08 +0200, Thomas Graf wrote:
> > > That creates a nice loop on ingress. Upon reentering the
> > > stack with skb->dev set to eth0 again we'll go through the
> > > same ingress filters as the first time and we'll hit ifb0
> > > again over and over. 
> > 
> > loops are taken care of by other metadata. 
> 
> Not really, assuming a simple setup such as:
> 
> 	mirred attached to eth0 redirecting to ifb0
> 	mirred attached to ifb0 redirecting to ifb1
> 
> will result in:
> 
> eth0::tcf_mirred()     skb->dev = ifb0, input_dev = eth0
> ifb0::tcf_mirred()     skb->dev = ifb1, input_dev = ifb0
> ifb1::ifb_xmit()       skb->dev = ifb0, input_dev = ifb1, set ncls bit
> ifb0::ifb_xmit()       skb->dev = ifb1, input_dev = ifb0
> ifb1::ifb_xmit()       skb->dev = ifb0, input_dev = ifb1
> ...
> 
> Oh dear... and we don't even have a ttl to catch this.
> 

Did you actually try to run this before you reached this conclusion?

> > I am going to ignore the patch until we resolve the issue of iif vs
> > input_dev. Why dont we discuss that?
> 
> It's starting to get useless to discuss with you. 

sigh.
ok, why dont you take a deep breath or a break because i think we are
not going to make any progress this way. I know you may be feeling
frustrated but i am equally if not more frustrated as well.
Our conflict comes in the fact that you are trying to change the
architecture in the name of fixing bugs. 
With all due respect, the architecture works. I have invested many many
hours testing and verifying. There may be coding bugs - and those need
fixing. Kill the bugs.

> You agreed in
> your last posting that the 3rd option, being that not caring about
> whether a device might disappear but having a way to check for it,
> is what we agreed on and what makes most sense, 

yes, i recalled that as the last discussion we had.

> yet you fail to see
> that using ifindex is exactly what reflects this descision.
> 

The choice is between using an ifindex and a pointer to the device. 
Why is it solvable via an ifindex but not a device pointer?
I may have misunderstood you, so look at this as a fresh opportunity to
enlighten me. Forget about all the discussion weve had thus far.

cheers,
jamal

