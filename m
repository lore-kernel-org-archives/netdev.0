From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Mon, 06 Aug 2012 17:24:02 -0700 (PDT)
Message-ID: <20120806.172402.650900841805469227.davem@davemloft.net>
References: <1344298429-19765-1-git-send-email-brutus@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: brutus@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756486Ab2HGAYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 20:24:08 -0400
In-Reply-To: <1344298429-19765-1-git-send-email-brutus@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Bruce \"Brutus\" Curtis" <brutus@google.com>
Date: Mon,  6 Aug 2012 17:13:49 -0700

> +			/*
> +			 * If friends haven't been made yet, our sk_friend
> +			 * still == NULL, then update with the ACK's friend
> +			 * value (the listen()er's sock addr) which is used
> +			 * as a place holder.
> +			 */
> +			atomic_long_cmpxchg(&sk->sk_friend, 0,
> +					    (u64)skb->friend);

You probably want plain:

	cmpxchg(&sk->sk_friend, NULL, skb->friend);

here.

Rather than using an expression that implies an equivalence between
the types 'long' and 'void *'
