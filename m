From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: fix percpu memory leaks
Date: Mon, 02 Nov 2015 19:32:03 +0100
Message-ID: <1446489123.3078652.426995233.777A4A93@webmail.messagingengine.com>
References: <1446483791.23275.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:47561 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753766AbbKBScF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 13:32:05 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 3D78D209D1
	for <netdev@vger.kernel.org>; Mon,  2 Nov 2015 13:32:04 -0500 (EST)
In-Reply-To: <1446483791.23275.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 2, 2015, at 18:03, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> This patch fixes following problems :
> 
> 1) percpu_counter_init() can return an error, therefore
>   init_frag_mem_limit() must propagate this error so that
>   inet_frags_init_net() can do the same up to its callers.
> 
> 2) If ip[46]_frags_ns_ctl_register() fail, we must unwind
>    properly and free the percpu_counter.
> 
> Without this fix, we leave freed object in percpu_counters
> global list (if CONFIG_HOTPLUG_CPU) leading to crashes.
> 
> This bug was detected by KASAN and syzkaller tool
> (http://github.com/google/syzkaller)
> 
> Fixes: 6d7b857d541e ("net: use lib/percpu_counter API for fragmentation
> mem accounting")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Syzkaller tool looks amazing, seems like it got support for unshare :).

Thanks!
