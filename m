From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Mon, 19 Jun 2006 10:36:50 -0400
Message-ID: <1150727810.5815.78.camel@jzny2>
References: <20060619121519.GA16031@gondor.apana.org.au>
	 <1150724031.5815.39.camel@jzny2>
	 <20060619134227.GA16662@gondor.apana.org.au>
	 <1150727009.5815.72.camel@jzny2>
	 <20060619142928.GA17191@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:39891 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932468AbWFSOgy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 10:36:54 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FsKs5-0004gE-O7
	for netdev@vger.kernel.org; Mon, 19 Jun 2006 10:36:57 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060619142928.GA17191@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-20-06 at 00:29 +1000, Herbert Xu wrote:

> Correct.  When qdisc_run happens we take an skb off the head of the
> queue.  If it can't be transmitted right away, we try to put it back
> in the same spot.
> 
> If you have two qdisc_run's happening at the same time then that spot
> could be different.
> 

Ok, but:
The queue lock will ensure only one of the qdisc runs (assuming
different CPUs) will be able to dequeue at any one iota in time, no?
And if you assume that the cpu that manages to get the tx lock as well
is going to be contending for the qlock in ordewr to requeue, then the
only scenario i can see the race happening is when you have one CPU
faster than the other.
Did i miss something?

cheers,
jamal

