From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Fri, 11 Oct 2013 11:21:45 +0200
Message-ID: <20131011092145.GT7660@secunet.com>
References: <20131010063301.GO7660@secunet.com>
 <525650F6.305@windriver.com>
 <20131010085703.GR7660@secunet.com>
 <5257A650.4090408@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36250 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044Ab3JKJVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Oct 2013 05:21:48 -0400
Content-Disposition: inline
In-Reply-To: <5257A650.4090408@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 11, 2013 at 03:18:40PM +0800, Fan Du wrote:
> >>In xfrm policy queue, XFRM_MAX_QUEUE_LEN is 100, which means 101th skb
> >>will be dropped, how about make it configurable?
> >
> >IMO we would have yet another useless knob then. Currently we send all
> >packets by default to a blackhole as long as the state is not resolved
> >and most people are fine with it. The queueing is mostly to speed up
> >tcp handshakes,
> 
> I cannot follow on this part. Would you please mind to explain how making a
> policy queue will speed up TCP handshakes than orignal CAN_SLEEP mechanism?
> 

I have not said that queueing is any faster than the sleeping mechanism.
But it is faster than the current default that simply sends the first
packets to a blackhole and can be used regardless if we can sleep.

All I wanted to say is that there are not many packets needed to establish
tcp connections, so I think a 100 packets queue is sufficient.
