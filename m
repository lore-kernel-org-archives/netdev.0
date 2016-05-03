From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add __sock_wfree() helper
Date: Tue, 03 May 2016 16:02:55 -0400 (EDT)
Message-ID: <20160503.160255.781749692228793045.davem@davemloft.net>
References: <1462211787.5535.269.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756372AbcECUC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:02:56 -0400
In-Reply-To: <1462211787.5535.269.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 May 2016 10:56:27 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Hosts sending lot of ACK packets exhibit high sock_wfree() cost
> because of cache line miss to test SOCK_USE_WRITE_QUEUE
> 
> We could move this flag close to sk_wmem_alloc but it is better
> to perform the atomic_sub_and_test() on a clean cache line,
> as it avoid one extra bus transaction.
> 
> skb_orphan_partial() can also have a fast track for packets that either
> are TCP acks, or already went through another skb_orphan_partial()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
