From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: out_of_order_queue do not use its lock
Date: Mon, 06 Jan 2014 16:35:24 -0500 (EST)
Message-ID: <20140106.163524.1758210592972482694.davem@davemloft.net>
References: <1389029772.12212.190.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754517AbaAFVf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:35:26 -0500
In-Reply-To: <1389029772.12212.190.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jan 2014 09:36:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP out_of_order_queue lock is not used, as queue manipulation
> happens with socket lock held and we therefore use the lockless
> skb queue routines (as __skb_queue_head())
> 
> We can use __skb_queue_head_init() instead of skb_queue_head_init()
> to make this more consistent.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

We should probably at some point try to make an sk_buff_head_lite
that only has the two pointers, so that we could shrink various
structures which have queues which we use like this.
