From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 13:32:11 -0400
Message-ID: <1151688732.5270.101.camel@jzny2>
References: <1151623394.8922.27.camel@jzny2>
	 <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2>
	 <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2>
	 <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2>
	 <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2>
	 <20060630163229.GH14627@postel.suug.ch>
	 <20060630171348.GI14627@postel.suug.ch>  <44A55CF8.2040509@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:40358 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932668AbWF3RcO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 13:32:14 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FwMqn-0006hS-Sg
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 13:32:17 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44A55CF8.2040509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 19:18 +0200, Patrick McHardy wrote:
> Thomas Graf wrote:
> > * Thomas Graf <tgraf@suug.ch> 2006-06-30 18:32
> > 
> >>Anyways, I give up. Last time I've been running after you trying
> >>to fix the many bugs you leave behind. Ever noticed that whenever
> >>you add some new code it's someone else following up with tons of
> >>small bugfix patches having a hard time trying to figure out the
> >>actual intent. I'll just duplicate the code for my purpose, so
> >>much easier.
> > 
> > 
> > There you go, leaves ifb broken as-is, at least prevents it
> > from crashing randomly when the input_dev disappears.
> 
> That would be a pity. After this patch has been ACKed, could we start
> over with the other bugs one at a time? I wasn't really able to gather
> the problems from this thread, but some of the behaviour you mentioned
> does seem questionable.
> 

I will summarize what the outstanding issues are, the rest of the "bugs"
just ignore otherwise the discussion is a waste of time and may
get out of control.

1) ifb references skb->input_dev
2) mirred sets the skb->input_dev which is used in #1

It is possible that when #1 happens infact input_dev is gone because no
ref count is incremented. Ok, Thomas is that sufficient to discuss the
crux of the matter?
At one point many months ago, the logic was for now the likelihood this
will happen is low but we need to cover for by at least figuring the
existence of input_dev when referencing it.

Thomas makes the claim, this can be achieved only by using an ifindex.
And i havent been able to see how. I have a small performance problem if
i just use ifindex. Using ifindex will eventually save 32 bits on the
64 bit machines. I posed the question as to which was more beneficial
as a solution that hasnt been addressed.


cheers,
jamal






