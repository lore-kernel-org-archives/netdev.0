From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: remove dst refcount false sharing for
 prequeue mode
Date: Tue, 09 Sep 2014 16:56:58 -0700 (PDT)
Message-ID: <20140909.165658.240781549171510851.davem@davemloft.net>
References: <1410188767.11872.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140908.142143.807176983873922125.davem@davemloft.net>
	<1410211842.11872.133.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbaIIX5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:57:00 -0400
In-Reply-To: <1410211842.11872.133.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Sep 2014 14:30:42 -0700

> In the worst case, here is what is happening :
> 
> sk_rx_dst is checked and invalidated in tcp_v4_do_rcv()
> 
> Next packets coming from prequeue might then have a NULL dst, and
> we'll do nothing special (sk_rx_dst will stay NULL), because we do
> handle NULL dst properly in inet_sk_rx_dst_set() and
> inet6_sk_rx_dst_set() 
> 
> But next packet to be processed (either in non prequeue mode or
> prequeue) will carry skb->dst and we will set sk->sk_rx_dst
> 
> I decided to not copy/paste the tests we do in the family dependent
> parts, because it was not worth the pain.

And, now applied.
