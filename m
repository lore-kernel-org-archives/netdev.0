From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fib: fix incorrect call_rcu_bh()
Date: Tue, 07 Aug 2012 18:48:14 +0200
Message-ID: <1344358094.28967.116.camel@edumazet-glaptop>
References: <1344336431.28967.14.camel@edumazet-glaptop>
	 <20120807163454.GF2378@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58711 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946Ab2HGQsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 12:48:19 -0400
Received: by bkwj10 with SMTP id j10so1522815bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 09:48:18 -0700 (PDT)
In-Reply-To: <20120807163454.GF2378@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 09:34 -0700, Paul E. McKenney wrote:
> On Tue, Aug 07, 2012 at 12:47:11PM +0200, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > After IP route cache removal, I believe rcu_bh() has very little use and
> > we should remove this RCU variant, since it adds some cycles in fast
> > path.
> 
> Do you mean remove all uses of RCU-bh globally and also removing the
> implementation itself?  That would actually be a good thing, from my
> perspective.
> 

Yes I meant that there are now too few rcu_bh users, and that they
probably could switch to regular rcu.

We could then remove the implementation.

rcu_bh was needed because we could sit forever in softirq mode in one
cpu, and we needed to allocate/free dsts with RCU protection.
