From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: suppress too verbose messages in
 tcp_send_ack()
Date: Wed, 02 Dec 2015 23:44:54 -0500 (EST)
Message-ID: <20151202.234454.571565058483226185.davem@davemloft.net>
References: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151130.110607.1409128209032271059.davem@redhat.com>
	<1448902648.24696.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbbLCEo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 23:44:56 -0500
In-Reply-To: <1448902648.24696.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Nov 2015 08:57:28 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> If tcp_send_ack() can not allocate skb, we properly handle this
> and setup a timer to try later.
> 
> Use __GFP_NOWARN to avoid polluting syslog in the case host is
> under memory pressure, so that pertinent messages are not lost under
> a flood of useless information.
> 
> sk_gfp_atomic() can use its gfp_mask argument (all callers currently
> were using GFP_ATOMIC before this patch)
> 
> We rename sk_gfp_atomic() to sk_gfp_mask() to clearly express this
> function now takes into account its second argument (gfp_mask)
> 
> Note that when tcp_transmit_skb() is called with clone_it set to false,
> we do not attempt memory allocations, so can pass a 0 gfp_mask, which
> most compilers can emit faster than a non zero or constant value.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: rename sk_gfp_atomic() to sk_gfp_mask()

Applied, thanks Eric.
