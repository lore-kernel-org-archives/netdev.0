From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: further fixes of possible seqlock deadlocks
Date: Thu, 28 Nov 2013 18:15:54 -0500 (EST)
Message-ID: <20131128.181554.1888077442034865299.davem@davemloft.net>
References: <1385672502.5352.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131128212700.GF24171@order.stressinduktion.org>
	<20131128221926.GG24171@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jongman.heo@samsung.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131128221926.GG24171@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 28 Nov 2013 23:19:26 +0100

> I don't really understand why we distinguish between _BH and plain ICMP stat
> calls then.
> 
> The non-_BH versions deactivate interrupts when updating the per-cpu counter.

This level of distinction exists back in the day where we did per-cpu counters
by hand.  We used to have a BH counter and a non-BH counter for each statistic
and it really helped performance wise.

These days most of that may not be so relevant any more.
