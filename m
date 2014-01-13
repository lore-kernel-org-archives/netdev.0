From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 2/5] net: mvneta: use per_cpu stats to fix an SMP lock up
Date: Mon, 13 Jan 2014 04:02:27 +0100
Message-ID: <20140113030227.GA18330@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu> <1389519069-1619-3-git-send-email-w@1wt.eu> <1389550056.31367.186.camel@edumazet-glaptop2.roam.corp.google.com> <20140112220921.GE16576@1wt.eu> <1389573903.31367.190.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55276 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110AbaAMDCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 22:02:33 -0500
Content-Disposition: inline
In-Reply-To: <1389573903.31367.190.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 12, 2014 at 04:45:03PM -0800, Eric Dumazet wrote:
> On Sun, 2014-01-12 at 23:09 +0100, Willy Tarreau wrote:
> 
> > But we can have multiple tx in parallel, one per queue. And it's only
> > when I explicitly bind two servers to two distinct CPU cores that I
> > can trigger the issue, which seems to confirm that this is the cause
> > of the issue.
> 
> So this driver has multiqueue ?

Yes, it defaults to 8 queues in each direction.

> Definitely it should have one syncp per queue.
> 
> Or per cpu stats, as your patch did.

OK thank you for your review and explanation then, I'm reassured :-)

Thanks,
Willy
