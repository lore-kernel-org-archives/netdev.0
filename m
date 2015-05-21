From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tcp: ensure epoll edge trigger wakeup when
 write queue is empty
Date: Thu, 21 May 2015 18:53:01 -0400 (EDT)
Message-ID: <20150521.185301.1643144249667063842.davem@davemloft.net>
References: <20150520155253.86202203D@prod-mail-relay06.akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbbEUWxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:53:03 -0400
In-Reply-To: <20150520155253.86202203D@prod-mail-relay06.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Wed, 20 May 2015 15:52:53 +0000 (GMT)

> From: Jason Baron <jbaron@akamai.com>
> 
> We currently rely on the setting of SOCK_NOSPACE in the write()
> path to ensure that we wake up any epoll edge trigger waiters when
> acks return to free space in the write queue. However, if we fail
> to allocate even a single skb in the write queue, we could end up
> waiting indefinitely.
> 
> Fix this by explicitly issuing a wakeup when we detect the condition
> of an empty write queue and a return value of -EAGAIN. This allows
> userspace to re-try as we expect this to be a temporary failure.
> 
> I've tested this approach by artificially making
> sk_stream_alloc_skb() return NULL periodically. In that case,
> epoll edge trigger waiters will hang indefinitely in epoll_wait()
> without this patch.
> 
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> ---
> v2:
> - ensure it compiles :)

Applied, thanks Jason :)
