From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] tcp: reduce out_of_order memory use
Date: Mon, 19 Mar 2012 16:57:55 -0400 (EDT)
Message-ID: <20120319.165755.1084666499514263609.davem@davemloft.net>
References: <1332077854.3722.52.camel@edumazet-laptop>
	<CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
	<1332104867.3597.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, therbert@google.com,
	ilpo.jarvinen@helsinki.fi, hkchu@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256Ab2CSU6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 16:58:10 -0400
In-Reply-To: <1332104867.3597.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 18 Mar 2012 14:07:47 -0700

> With increasing receive window sizes, but speed of light not improved
> that much, out of order queue can contain a huge number of skbs, waiting
> to be moved to receive_queue when missing packets can fill the holes.
> 
> Some devices happen to use fat skbs (truesize of 4096 + sizeof(struct
> sk_buff)) to store regular (MTU <= 1500) frames. This makes highly
> probable sk_rmem_alloc hits sk_rcvbuf limit, which can be 4Mbytes in
> many cases.
> 
> When limit is hit, tcp stack calls tcp_collapse_ofo_queue(), a true
> latency killer and cpu cache blower.
> 
> Doing the coalescing attempt each time we add a frame in ofo queue
> permits to keep memory use tight and in many cases avoid the
> tcp_collapse() thing later.
> 
> Tested on various wireless setups (b43, ath9k, ...) known to use big skb
> truesize, this patch removed the "packets collapsed in receive queue due
> to low socket buffer" I had before.
> 
> This also reduced average memory used by tcp sockets.
> 
> With help from Neal Cardwell.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
