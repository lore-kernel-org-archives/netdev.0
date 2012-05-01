From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 net-next] tcp: makes tcp_try_coalesce aware of
 skb->head_frag
Date: Mon, 30 Apr 2012 21:48:47 -0400 (EDT)
Message-ID: <20120430.214847.426130586624369879.davem@davemloft.net>
References: <1335523113.2775.239.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com,
	jeffrey.t.kirsher@intel.com, therbert@google.com,
	herbert@gondor.hengli.com.au, bhutchings@solarflare.com,
	mcarlson@broadcom.com, mchan@broadcom.com, maze@google.com,
	ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757652Ab2EABtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:49:06 -0400
In-Reply-To: <1335523113.2775.239.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Apr 2012 12:38:33 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP coalesce can check if skb to be merged has its skb->head mapped to a
> page fragment, instead of a kmalloc() area.
> 
> We had to disable coalescing in this case, for performance reasons.
> 
> We 'upgrade' skb->head as a fragment in itself.
> 
> This reduces number of cache misses when user makes its copies, since a
> less sk_buff are fetched.
> 
> This makes receive and ofo queues shorter and thus reduce cache line
> misses in TCP stack.
> 
> This is a followup of patch "net: allow skb->head to be a page fragment"
> 
> Tested with tg3 nic, with GRO on or off. We can see "TCPRcvCoalesce"
> counter being incremented.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
