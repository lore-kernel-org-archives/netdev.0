From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] truesize lies
Date: Sun, 09 Oct 2011 17:27:39 -0400 (EDT)
Message-ID: <20111009.172739.2151675769111763947.davem@davemloft.net>
References: <1318186948.5276.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab1JIV1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 17:27:41 -0400
In-Reply-To: <1318186948.5276.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Oct 2011 21:02:28 +0200

> I guess most driver writers adjust truesize to please TCP stack and get
> nice performance numbers.
> 
> skb->truesize = frame_len + sizeof(sk_buff);
> 
> What should we do exactly ?

We should pick a specification that accounts for all the metadata as well
as unused data areas properly, and enforce this in netif_receive_skb().

That will get the inaccurate cases fixed real fast.

We've had similar problems in the past and dealt with it in the same
exact way.
