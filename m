From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] poll: Avoid extra wakeups
Date: Tue, 28 Apr 2009 16:21:38 +0200
Message-ID: <87ab60rh8t.fsf@basil.nowhere.org>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>
	<49F3308B.1030507@cosmosbay.com>
	<20090426.020411.157511269.davem@davemloft.net>
	<49F43B8F.2050907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41225 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319AbZD1OVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 10:21:43 -0400
In-Reply-To: <49F43B8F.2050907@cosmosbay.com> (Eric Dumazet's message of "Sun, 26 Apr 2009 12:46:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> writes:
>
> When scheduled, thread does a full scan of all polled fds and
> can sleep again, because nothing is really available. If number
> of fds is large, this cause significant load.

I wonder if the key could be used for more state. For example if you
two processes are in recvmsg() on a socket and there's only a single
packet incoming we only need to wake up the first waiter.  Could that
be done with keys too?

> This patch makes select()/poll() aware of keyed wakeups and
> useless wakeups are avoided. This reduces number of context
> switches by about 50% on some setups, and work performed
> by sofirq handlers.

I'm late, but: very cool patch too.

Acked-by: Andi Kleen <ak@linux.intel.com>

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
