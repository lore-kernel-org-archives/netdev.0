From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 17:31:37 -0400
Message-ID: <1151703097.5270.307.camel@jzny2>
References: <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2>
	 <20060630203034.GN14627@postel.suug.ch>
	 <20060630.133348.68039806.davem@davemloft.net>
	 <1151700884.5270.278.camel@jzny2>  <20060630211043.GO14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:10440 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932274AbWF3Vbo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 17:31:44 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FwQaW-0006KY-9R
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 17:31:44 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630211043.GO14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 23:10 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 16:54
> > I agree - and i try hard to document but at times there's too much
> > and a line needs to be drawn.
> > As an example:
> > the eth->ifb->ifb case though is a very corner case. All the IMQ types
> > need to only redirect to one ifb; while i test it ive always seen the
> > test as more of a boundary check than a useful setup.
> 
> Maybe you should just start by explaining why it doesn't work,
> your original explanation doesn't make much sense.
> 

Better to explain the reason for ifb first:
ifb exists initially as a replacement for IMQ. 
1) qdiscs/policies that are per device as opposed to system wide.
This now allows for sharing.

2) Allows for queueing incoming traffic for shaping instead of
dropping.

In other wise, the main use is for multiple devices to redirect to it.
Main desire is not for it to redirect to any other ifb device or eth
devices. I actually tried to get it to do that, but run into issues
of complexity and and came up with decision to drop instead of killing
the machine.
Other than that, it can redirect to any other devices - but may still
not be meaningful.

I have been thinking of Herberts change of qdisc_is_running and this may
help actually.

> > And Thomas: I do keep notebooks ;-> I doodle about everything, they dont
> > all fit in my knapsack anymore so sometimes when i say i will go and
> > refer to my notes, it is real.
> 
> It's plain arrogant to rely code understanding on information that
> is not available to others. It makes everyone being dependant on
> you, very nice.
> 

I try hard to document more than many many people. I give tutorials, I
write papers when time allows, I spend time responding to emails. And i
do it all for the love of the game. 
But lets look at the other side of the coin:
Dont you think it is polite to ask when something is not clear instead
of making assumptions? 

> To put it in another way, if you would do your job right when
> writing the code, contacting or CCing you upon changes would
> be only of a formal matter since the code is understandable and
> the intent is clear or documented.

I wish I could achieve that. I dont think theres any piece of code that
reaches those standards in the kernel actually. And if theres a piece of
code that achieves that it should be emulated. Most of the times, things
that are hard are not about the code but about issues like algorithmics,
embedded policies etc (I think you are saying the same).

cheers,
jamal

