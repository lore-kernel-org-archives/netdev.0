From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet scheduling
	for	ATM/ADSL (kernel)
Date: Mon, 23 Oct 2006 21:22:06 +1000
Message-ID: <1161602527.5502.155.camel@ras.pc.stuart.local>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:58542 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1751917AbWJWLWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 07:22:33 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45378DE3.8080700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-10-19 at 16:38 +0200, Patrick McHardy wrote:
> I still think this patch shouldn't go in. There's no point in doing the
> same thing twice, and I haven't heard a compelling argument why it has
> to be done in a way that only helps qdiscs using rtabs while ignoring
> statistics and estimators (I even provided a patch to show how to do
> it without these limitations).

As far as I can see one patch changes the way the 
kernel calculates packet lengths, and the other modifies 
RTAB.  I can not see the significant overlap between the 
patches that you talk about.

As for why haven't got a new patch from me that addresses 
the "doing the same thing twice" issue - it is because I
can see no such issue.  I have asked you repeatedly to
explain it further, but you have not done so.

As for "providing a patch" - I believe at the time you
called it something you were working on.  As far as I
know you still are working on it.  Besides, even if you
did intend me to take it further, I am not particularly 
interested in the packet length issue as it does not 
effect the real world performance of any of the qdiscs 
I use.

> Besides that:
> 
> +static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, int pktlen)
> +{
> +	int slot = pktlen + rtab->rate.cell_align;
> +	if (slot < 0)
> +	  	slot = 0;
> 
> Why would it go negative? A negative cell_align doesn't make sense I
> guess.

A negative cell align is possible, and in fact is typical.
If slot ended up being less than 0 then the configuration
parameters passed to "tc" would of been wrong - they could
not of matched the actual traffic.  The error can't be 
detected in "tc", but it can't be allowed to cause the
kernel to index off the end of an array either.

> +	slot >>= rtab->rate.cell_log;
> +	if (slot > 255)
> +		return rtab->data[255] + 1;
> 
> Whats the point of this? Is it just to keep htb giant statistics
> working?

Yes.

