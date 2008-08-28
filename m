From: Andi Kleen <andi@firstfloor.org>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 09:45:36 +0200
Message-ID: <20080828074536.GK26610@one.firstfloor.org>
References: <48B5DE9F.4010000@cosmosbay.com> <20080827.161504.183610665.davem@davemloft.net> <48B5E6A3.6@cosmosbay.com> <20080827.164535.150037784.davem@davemloft.net> <48B5F3E2.2000909@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	davej@redhat.com, netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54863 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733AbYH1HnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 03:43:01 -0400
Content-Disposition: inline
In-Reply-To: <48B5F3E2.2000909@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When scanning route cache hash table, we can avoid taking locks for empty 
> buckets.

I'm not sure it's worth it in this case.  A rcu_read_lock() is a nop
(on non preemptible kernel) to very cheap (non atomic increment/decrement in 
cached task_struct) 

If you really wanted to make it faster I think a better strategy
would be to not take it every bucket, but maybe only every 100th
or so. That would still keep preempt off times reasonably low, but
even help when the table is filled. But not sure it would 
be even measurable, really it should be quite cheap.

-Andi

