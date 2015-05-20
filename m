From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: ensure epoll edge trigger wakeup when
 write queue is empty
Date: Wed, 20 May 2015 10:09:56 -0700
Message-ID: <1432141796.4060.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150520155253.86202203D@prod-mail-relay06.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37244 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbbETRJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 13:09:59 -0400
Received: by igbsb11 with SMTP id sb11so45051138igb.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 10:09:58 -0700 (PDT)
In-Reply-To: <20150520155253.86202203D@prod-mail-relay06.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 15:52 +0000, Jason Baron wrote:
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

Acked-by: Eric Dumazet <edumazet@google.com>
