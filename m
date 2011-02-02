From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv4: Remove fib_hash.
Date: Wed, 2 Feb 2011 08:29:21 -0800
Message-ID: <20110202082921.7eee82e0@nehalam>
References: <20110201.151941.48509941.davem@davemloft.net>
	<1296607693.2607.7.camel@edumazet-laptop>
	<20110201.181542.193701016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40900 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754345Ab1BBQ30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 11:29:26 -0500
In-Reply-To: <20110201.181542.193701016.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Feb 2011 18:15:42 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 Feb 2011 01:48:13 +0100
> 
> > Hmm... I know having to maintain two implementations is time consuming,
> > but I know fib_trie is bigger :
> > 
> > # size net/ipv4/fib_*.o
> >    text	   data	    bss	    dec	    hex	filename
> >    7252	    120	      0	   7372	   1ccc	net/ipv4/fib_frontend.o
> >    7279	     16	      4	   7299	   1c83	net/ipv4/fib_hash.o
> >    1479	      0	      0	   1479	    5c7	net/ipv4/fib_rules.o
> >    7885	      0	   2080	   9965	   26ed	net/ipv4/fib_semantics.o
> >   16222	     16	     16	  16254	   3f7e	net/ipv4/fib_trie.o
> > 
> > In my tests, I know that fib_trie is more expensive for typical routing
> > tables for hosts (no more than a dozen or entries), in latencies
> > results, mostly because of icache misses, but also dcache ones.
> 
> It's mostly the rebalancing code that takes up the space.
> 
> The lookup path is on the same order of magnitude as the fib hash
> stuff was.
> 
> In any event, we have several months to hash out any regressions and I
> think if I didn't do this removal nobody would work on it so... :-)

For the case of small devices, what about keeping fib_hash as option
under CONFIG_EMBEDDED. And remove all the magic resizing of hash table.
Get back to something with really small size.

-- 
