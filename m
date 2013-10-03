From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp/dccp: remove twchain
Date: Thu, 03 Oct 2013 14:58:11 -0700
Message-ID: <1380837491.19002.240.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380784922.19002.198.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003.175107.1919190333940976775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:51867 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151Ab3JCV6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:58:12 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so3238463pad.0
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 14:58:12 -0700 (PDT)
In-Reply-To: <20131003.175107.1919190333940976775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 17:51 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 03 Oct 2013 00:22:02 -0700
> 
> > Current inet_ehash_bucket contains two chains, one for ESTABLISH (and
> > friend states) sockets, another for TIME_WAIT sockets only.
> > 
> > As the hash table is sized to get at most one socket per bucket, it
> > makes little sense to have separate twchain, as it makes the lookup
> > slightly more complicated, and doubles hash table memory usage.
> 
> The idea was that long standing time-wait sockets should be forced to
> provably never appear in same hash chains and thus cause interference
> with lookups on established sockets.
> 
> On the other hand, moving sockets between these two tables has a
> non-trivial cost, and synchronization complexity.
> 
> So perhaps your change gives the right tradeoff.
> 
> Eric this patch needs to be respun against current net-next
> in order for it to apply cleanly, please do that and I'll add
> it.

I think the main problem comes from this commit in net tree ?

commit 80ad1d61e72d626e30ebe8529a0455e660ca4693
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Oct 1 21:04:11 2013 -0700

    net: do not call sock_put() on TIMEWAIT sockets
    
    commit 3ab5aee7fe84 ("net: Convert TCP & DCCP hash tables to use RCU /
    hlist_nulls") incorrectly used sock_put() on TIMEWAIT sockets.
    
    We should instead use inet_twsk_put()

I think you could safely ignore the warnings
because of (tcp: shrink tcp6_timewait_sock by one cache line) latest changes

patching file include/net/inet_timewait_sock.h
Hunk #1 succeeded at 141 (offset 5 lines).
Hunk #2 succeeded at 180 (offset 5 lines).

Please tell me if I need to resend, thanks
