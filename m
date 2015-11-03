From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix percpu memory leaks
Date: Mon, 02 Nov 2015 22:47:39 -0500 (EST)
Message-ID: <20151102.224739.1048362049247992500.davem@davemloft.net>
References: <1446483791.23275.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, dvyukov@google.com,
	hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbbKCDrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 22:47:41 -0500
In-Reply-To: <1446483791.23275.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2015 09:03:11 -0800

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
> Fixes: 6d7b857d541e ("net: use lib/percpu_counter API for fragmentation mem accounting")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied.
