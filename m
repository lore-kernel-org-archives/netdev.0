From: Andi Kleen <andi@firstfloor.org>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 15:03:56 -0700
Message-ID: <m2vcx9x9v7.fsf@firstfloor.org>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<1305663288.2691.2.camel@edumazet-laptop>
	<m2aaelypbp.fsf@firstfloor.org>
	<1305669140.6741.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29751 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932389Ab1EQWE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 18:04:29 -0400
In-Reply-To: <1305669140.6741.4.camel@edumazet-laptop> (Eric Dumazet's message
	of "Tue, 17 May 2011 23:52:20 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

>> They're not rwlocks, but especially if the locking was more finegrained
>> that's likely not needed anymore.
>
> Well, there is the rehashing stuff, and this locks the whole table.
>
> Not easy to switch to rcu or something like that.

No need to switch to RCU, just a more finegrained bucket lock.

If you move a chain between queues you just lock both for the move.
It sounds easy enough. I should probably just code it up.

>
> Anyway I hardly use frags here at work, so never considered it was a
> field to spend time ;)

Yes that's the problem. On the other hand most scalability problems hurt
sooner or later, so sometimes it's good to fix them in advance.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
