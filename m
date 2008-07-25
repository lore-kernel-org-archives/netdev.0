From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Fri, 25 Jul 2008 22:01:37 +0200
Message-ID: <20080725200137.GC3107@ami.dom.local>
References: <1216806614.7257.152.camel@twins> <1216810696.7257.175.camel@twins> <20080723.131441.200166513.davem@davemloft.net> <200807251904.37302.netdev@axxeo.de> <20080725183622.GA3107@ami.dom.local> <1217013384.4758.5.camel@johannes.berg> <20080725193416.GB3107@ami.dom.local> <1217014575.4758.7.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Oeser <netdev@axxeo.de>, David Miller <davem@davemloft.net>,
	peterz@infradead.org, Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:21449 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbYGYUA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 16:00:29 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2827999ika.5
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 13:00:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1217014575.4758.7.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 09:36:15PM +0200, Johannes Berg wrote:
> On Fri, 2008-07-25 at 21:34 +0200, Jarek Poplawski wrote:
> 
> > > Umm, of course it cannot, because then we'd have to take the mutex in
> > > the TX path, which we cannot. We cannot have another lock in the TX
> > > path, what's so hard to understand about? We need to be able to lock all
> > > queues to lock out multiple tx paths at once in some (really) slow paths
> > > but not have any extra lock overhead for the tx path, especially not a
> > > single lock.
> > 
> > But this mutex doesn't have to be mutex. And it's not for the tx path,
> > only for "service" just like netif_tx_lock(). The fast path needs only
> > queue->tx_lock.
> 
> No, we need to be able to lock out multiple TX paths at once.

IMHO, it can do the same. We could e.g. insert a locked spinlock into
this noop_tx_handler(), to give everyone some waiting.

Jarek P.
