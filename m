From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 04:36:23 -0400 (EDT)
Message-ID: <20120426.043623.1317043382565428400.davem@davemloft.net>
References: <alpine.DEB.2.00.1204241131580.735@wel-95.cs.helsinki.fi>
	<1335257803.5205.133.camel@edumazet-glaptop>
	<1335427854.2775.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, rick.jones2@hp.com,
	netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	maze@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754908Ab2DZIgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 04:36:49 -0400
In-Reply-To: <1335427854.2775.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Apr 2012 10:10:54 +0200

> Idea would have :
> 
> 1) struct sk_buff
> 2) skb->head points to frag (aliasing, no memory allocation)
> 3) frag of 2048 (or PAGE_SIZE/2 or PAGE_SIZE)

What would you set skb->data_len and skb->len to?

How would you handle tailroom?  We have the rule that you can't append
to the tail of a fragmented SKB (I mean append, the way that IPSEC
wants to write data to the end of an SKB when encrypting, for
example).  This is only allowed on fully linear SKBs.

So, for this reason and others, you can't pretend that this new
construction is linear in any way.  It would break a bunch of things.
