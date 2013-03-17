From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Sun, 17 Mar 2013 09:52:49 -0700
Message-ID: <1363539169.29475.78.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>
	 <51356AC1.4090302@gmail.com> <1362460046.15793.111.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>
	 <1362494795.15793.113.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303061631290.6723@dflat>
	 <1362663990.15793.208.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303141359080.16308@dflat>
	 <1363301786.29475.40.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303141610490.16308@dflat>
	 <1363303174.29475.46.camel@edumazet-glaptop>
	 <1363455366.29475.66.camel@edumazet-glaptop>
	 <1363455885.29475.68.camel@edumazet-glaptop>
	 <alpine.DEB.2.02.1303170218460.28650@dflat>
	 <1363538008.29475.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:56742 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756252Ab3CQQww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:52:52 -0400
In-Reply-To: <1363538008.29475.73.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-17 at 09:33 -0700, Eric Dumazet wrote:
> On Sun, 2013-03-17 at 02:21 -0700, dormando wrote:
> 
> > Hope you don't mind a screenshot:
> > http://www.dormando.me/p/3.8.2-trace-crash.jpg
> > 
> > (I put the patches on 3.8.2). box is on another continent so screenshot
> > via IPMI is what I get. If this isn't enough or isn't right I'll try
> > harder to get the trace logged, I guess?
> 
> Thanks a lot, this gives another useful input, no need for more traces
> for the moment.
> 
> Could you send me the disassembly of tcp_release_cb() ?
> 
> (objdump -d vmlinux | filter to get tcp_release_cb() body)
> 
> 

It seems we can have a refcnt imbalance because of

atomic_set(&newsk->sk_refcnt, 2);

we do in sk_clone_lock()

Somehow, something is wrong, because at this point the socket should not
be found.

We perform a sock_hold() somewhere while the socket is already dead.

I'll send a patch asap
