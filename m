From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Restore old dst_free() behavior.
Date: Tue, 31 Jul 2012 07:54:57 +0200
Message-ID: <1343714097.21269.38.camel@edumazet-glaptop>
References: <20120730.223827.74792864437911339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:41270 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab2GaFzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 01:55:02 -0400
Received: by wibhr14 with SMTP id hr14so2504554wib.1
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2012 22:55:01 -0700 (PDT)
In-Reply-To: <20120730.223827.74792864437911339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-30 at 22:38 -0700, David Miller wrote:
> Eric, this is what I'd like to propose.
> 
> It seems the problem you were likely running into was simply
> the fact that we were not inserting an RCU grace period for
> the dst_free() that we do when purging a FIB nexthop.
> 
> So this reverts your change, and instead adds the necessary
> call_rcu_bh() wrapper around the dst_free() done in fib_semantics.c
> 
> That makes it so that we don't need all of that inc_not_zero stuff for
> sockets, and the special dst flag.  If we set the pointer to NULL,
> then do the dst_free() via RCU, we can test that refcount safely in
> dst_free() since it can only decrease at that point.
> 
> What do you think?  Does it pass your tests?
> 
> Thanks.

I'll test that ASAP, I was trying to understand why Linus tree gave me a
non workable machine ( a panic in igb driver ... NULL RIP) .

I dont understand how I did not have this bug with net tree.

Please give me a couple of hours, I need to break my fast ;)
