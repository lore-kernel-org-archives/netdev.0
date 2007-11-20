From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from
 softirq to workqueue
Date: Mon, 19 Nov 2007 22:43:57 -0800 (PST)
Message-ID: <20071119.224357.33938372.davem@davemloft.net>
References: <20071116174027.726e6eca.dada1@cosmosbay.com>
	<20071116.165445.172804063.davem@davemloft.net>
	<473EB75B.7000607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756772AbXKTGn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:43:58 -0500
In-Reply-To: <473EB75B.7000607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 17 Nov 2007 10:41:47 +0100

> [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softirq to workqueue
> 
> Every 600 seconds (ip_rt_secret_interval), a softirq flush of the whole
> ip route cache is triggered. On loaded machines, this can starve softirq for
> many seconds and can eventually crash.
> 
> This patch moves this flush to a workqueue context, using the worker we
> intoduced in commit 39c90ece7565f5c47110c2fa77409d7a9478bd5b
> (IPV4: Convert rt_check_expire() from softirq processing to workqueue.)
> 
> Also, immediate flushes (echo 0 >/proc/sys/net/ipv4/route/flush) are using
> rt_do_flush() helper function, wich take attention to rescheduling.
> 
> Next step will be to handle delayed flushes
> ("echo -1 >/proc/sys/net/ipv4/route/flush"  or
> "ip route flush cache")
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
