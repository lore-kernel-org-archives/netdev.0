From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: do not block bh too long in
 inet_twdr_twkill_work()
Date: Sun, 12 Apr 2015 21:04:56 -0400 (EDT)
Message-ID: <20150412.210456.227234180754411318.davem@davemloft.net>
References: <1428664747.25985.298.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbbDMBE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 21:04:58 -0400
In-Reply-To: <1428664747.25985.298.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Apr 2015 04:19:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I have seen inet_twdr_twkill_work() blocking softirq for
> periods up to 1.5 seconds, depending on number of timewait sockets.
> 
> This is an unacceptable source of latency.
> 
> Note that inet_twdr_do_twkill_work() releases death_lock spinlock
> for every tw handled, but does not take care of bh enabling.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I think it makes sense to use local_softirq_pending() here rather
than flip the lock unconditionally.
