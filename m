From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 net-next 1/2] net: add skb_mstamp infrastructure
Date: Wed, 26 Feb 2014 17:04:25 -0500 (EST)
Message-ID: <20140226.170425.1796947766908119120.davem@davemloft.net>
References: <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393309324.2316.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393452131.26794.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, ycheng@google.com, netdev@vger.kernel.org,
	ncardwell@google.com, brakmo@google.com, stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754293AbaBZWE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:04:28 -0500
In-Reply-To: <1393452131.26794.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Feb 2014 14:02:11 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> ktime_get() is too expensive on some cases, and we'd like to get
> usec resolution timestamps in TCP stack.
> 
> This patch adds a light weight facility using a combination of
> local_clock() and jiffies samples.
> 
> Instead of :
> 
>         u64 t0, t1;
> 
>         t0 = ktime_get();
>         // stuff
>         t1 = ktime_get();
>         delta_us = ktime_us_delta(t1, t0);
> 
> use :
>         struct skb_mstamp t0, t1;
> 
>         skb_mstamp_get(&t0);
>         // stuff
>         skb_mstamp_get(&t1);
>         delta_us = skb_mstamp_us_delta(&t1, &t0);
> 
> Note : local_clock() might have a (bounded) drift between cpus.
> 
> Do not use this infra in place of ktime_get() without understanding the
> issues.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
