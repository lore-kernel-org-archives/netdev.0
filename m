From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice: fix an infinite loop in tcp_read_sock()
Date: Fri, 11 Jan 2013 00:21:53 +0100
Message-ID: <20130110232153.GE17390@1wt.eu>
References: <1357837570.27446.2285.camel@edumazet-glaptop> <20130110230145.GC17390@1wt.eu> <1357859155.27446.2768.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:38326 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431Ab3AJXWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 18:22:01 -0500
Content-Disposition: inline
In-Reply-To: <1357859155.27446.2768.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2013 at 03:05:55PM -0800, Eric Dumazet wrote:
> On Fri, 2013-01-11 at 00:01 +0100, Willy Tarreau wrote:
> > Hi Eric,
> 
> > Thanks for catching this one. I'm amazed we didn't notice it earlier,
> > I've been running my stress-test kernels with this patch applied since
> > we did it.
> > 
> 
> Thats because you splice(    very_large_amount_of_bytes), so you dont
> hit this bug.

Not always, I use many sizes (from 1k to very large).

> netperf does the splice (    exact_amount_of_bytes ) so hits this pretty
> fast on loopback at least.

OK I see, if we need an exact size to trigger it, that explains it !

Thanks for the explanation,
Willy
