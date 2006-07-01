From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 1 Jul 2006 13:28:33 +0200
Message-ID: <20060701112833.GS14627@postel.suug.ch>
References: <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2> <20060630203034.GN14627@postel.suug.ch> <20060630.133348.68039806.davem@davemloft.net> <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch> <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch> <1151722785.5093.51.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:40911 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932792AbWGAL2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2006 07:28:13 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151722785.5093.51.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 22:59
> On Sat, 2006-01-07 at 01:45 +0200, Thomas Graf wrote:
> > Fact is that the from verdict is set to a meaningful value again at 
> > dev_queue_xmit() or ing_filter() so ifb_xmit() only sees valid values. 
> 
> Ok, Thomas this is one of those places where we end up colliding for no
> good reason - your statement above is accusatory. And sometimes i say 3
> things and you pick one and use that as context. The ifb does clear the
> field. So if you get redirected again, it will be 0.

Please enlighten me, I may be making a wrong assumption again.

1) tc_verd is reset to 0 after dq in ri_tasklet()
2) TC_AT is set to AT_EGRESS in dev_queue_xmit()
3) TC_FROM being derived from TC_AT in tcf_mirred() when redirecting
4) TC_FROM has the value AT_EGRESS when entering ifb_xmit()

> different instances of the same device do not deadlock. If however, you
> have a series of devices in which A->B->C->D->A then you will have a
> possible deadlock. In the case of the ifb i dissallowed it because it
> was obvious from the testing. 

Correct me if I'm wrong. The skb is queued between each device. When
moving skbs from rq to tq the tx lock is acquired, if not available
the packet is requeued for later. Due to the queueing the tx lock
of the previous device is released. Where exactly is the deadlock?
