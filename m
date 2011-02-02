From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove fib_hash.
Date: Tue, 01 Feb 2011 18:15:42 -0800 (PST)
Message-ID: <20110201.181542.193701016.davem@davemloft.net>
References: <20110201.151941.48509941.davem@davemloft.net>
	<1296607693.2607.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35847
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752177Ab1BBCPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 21:15:07 -0500
In-Reply-To: <1296607693.2607.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Feb 2011 01:48:13 +0100

> Hmm... I know having to maintain two implementations is time consuming,
> but I know fib_trie is bigger :
> 
> # size net/ipv4/fib_*.o
>    text	   data	    bss	    dec	    hex	filename
>    7252	    120	      0	   7372	   1ccc	net/ipv4/fib_frontend.o
>    7279	     16	      4	   7299	   1c83	net/ipv4/fib_hash.o
>    1479	      0	      0	   1479	    5c7	net/ipv4/fib_rules.o
>    7885	      0	   2080	   9965	   26ed	net/ipv4/fib_semantics.o
>   16222	     16	     16	  16254	   3f7e	net/ipv4/fib_trie.o
> 
> In my tests, I know that fib_trie is more expensive for typical routing
> tables for hosts (no more than a dozen or entries), in latencies
> results, mostly because of icache misses, but also dcache ones.

It's mostly the rebalancing code that takes up the space.

The lookup path is on the same order of magnitude as the fib hash
stuff was.

In any event, we have several months to hash out any regressions and I
think if I didn't do this removal nobody would work on it so... :-)
