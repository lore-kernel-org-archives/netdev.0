From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sock: fix TCP_SKB_MIN_TRUESIZE
Date: Wed, 03 Jul 2013 16:52:55 -0700 (PDT)
Message-ID: <20130703.165255.2199744750245012601.davem@davemloft.net>
References: <1371644355.3252.307.camel@edumazet-glaptop>
	<20130619.211721.1594350084165223337.davem@davemloft.net>
	<1372852942.4979.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278Ab3GCXw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 19:52:56 -0400
In-Reply-To: <1372852942.4979.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 03 Jul 2013 05:02:22 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit eea86af6b1e18d ("net: sock: adapt SOCK_MIN_RCVBUF and
> SOCK_MIN_SNDBUF") forgot the sk_buff alignment taken into account
> in __alloc_skb() : skb->truesize = SKB_TRUESIZE(size);
> 
> While above commit fixed the sender issue, the receiver is still
> dropping the second packet (on loopback device), because the receiver
> socket can not really hold two skbs :
> First packet truesize already is above sk_rcvbuf, so even TCP coalescing
> cannot help.
> 
> On a typical 64bit build, each tcp skb truesize is 2304, instead of 2272
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
