From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 19:42:51 +0200
Message-ID: <20060630174251.GK14627@postel.suug.ch>
References: <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <20060630171348.GI14627@postel.suug.ch> <44A55CF8.2040509@trash.net> <1151688732.5270.101.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:9146 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932909AbWF3Rma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 13:42:30 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151688732.5270.101.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 13:32
> I will summarize what the outstanding issues are, the rest of the "bugs"
> just ignore otherwise the discussion is a waste of time and may
> get out of control.
> 
> 1) ifb references skb->input_dev
> 2) mirred sets the skb->input_dev which is used in #1
> 
> It is possible that when #1 happens infact input_dev is gone because no
> ref count is incremented. Ok, Thomas is that sufficient to discuss the
> crux of the matter?

Sure, that's the most obvious bug.

> At one point many months ago, the logic was for now the likelihood this
> will happen is low but we need to cover for by at least figuring the
> existence of input_dev when referencing it.
>
> Thomas makes the claim, this can be achieved only by using an ifindex.
> And i havent been able to see how. I have a small performance problem if
> i just use ifindex. Using ifindex will eventually save 32 bits on the
> 64 bit machines. I posed the question as to which was more beneficial
> as a solution that hasnt been addressed.

I'd appreciate if you'd stop sperading lies. I claimed it to be the
best solution, not the only one. Everyone agrees that it's possible
to use a pointer and take a reference in netif_receive_skb() while
it also seems obvious to most that it's not a good idea to take two
additional atomic operations in the fast path for this purpose.
