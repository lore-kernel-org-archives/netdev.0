From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 05:18:00 -0400 (EDT)
Message-ID: <20120426.051800.637617874638567499.davem@davemloft.net>
References: <1335427854.2775.15.camel@edumazet-glaptop>
	<20120426.043623.1317043382565428400.davem@davemloft.net>
	<1335431402.2775.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, rick.jones2@hp.com,
	netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	maze@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123Ab2DZJSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:18:25 -0400
In-Reply-To: <1335431402.2775.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Apr 2012 11:10:02 +0200

> The 'frag' would have a known size : 2048 bytes
> 
> But the end of it would be used by struct skb_shared_info
> 
> so data_len would be 0 in fact.
> 
> This would look like a regular linear skb.
> 
> Just a bit set in skb to say : Warning, skb->head was not kmalloced :
> replace kfree(head) by put_page(...)
> 
> And this bit would be tested in GRO or tcp merge to 'upgrade' this
> skb->head to proper page/frag

And what happens if this ends up in a piece of code which wants to
append a page frag?

Or a piece of code which copies an SKB, including page frag parts?

All I'm saying is that the number of tests necessary to make this work
properly might become prohibitive.
