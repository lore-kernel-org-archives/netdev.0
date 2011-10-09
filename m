From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] truesize lies
Date: Sun, 09 Oct 2011 18:10:23 -0400 (EDT)
Message-ID: <20111009.181023.328192272226333109.davem@davemloft.net>
References: <1318186948.5276.49.camel@edumazet-laptop>
	<20111009.172739.2151675769111763947.davem@davemloft.net>
	<1318197320.21116.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab1JIWK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 18:10:28 -0400
In-Reply-To: <1318197320.21116.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Oct 2011 23:55:20 +0200

> Some drivers splits a page in two (or more) pieces, so we cant know what
> was really reserved by a driver for paged skbs.
> 
> Only thing we could enforce at the moment is the proper accounting for
> skb head :
> 
> WARN_ON(skb->truesize < (skb_end_pointer(skb) - skb->head) + sizeof(sk_buff) + skb->data_len);

This is partly true.

Drivers that use page pools divide pages up into different pools, each
with some specific block size.  At least this is how NIU works.

So NIU knows exactly how much of the block is logically part of that
SKB yet unused.

And if we really wanted to we could add a frag[].reserved field that
keeps track of this for debugging.
