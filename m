From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next 1/2] net: add skb_mstamp infrastructure
Date: Wed, 26 Feb 2014 15:02:46 -0500 (EST)
Message-ID: <20140226.150246.2032724506200600118.davem@davemloft.net>
References: <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393309324.2316.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, ja@ssi.bg, ycheng@google.com,
	netdev@vger.kernel.org, ncardwell@google.com, brakmo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaBZUCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:02:49 -0500
In-Reply-To: <1393309324.2316.119.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Feb 2014 22:22:04 -0800

> Instead of :
> 
> 	u64 t0, t1;
> 
> 	t0 = ktime_get();
> 	// stuff
> 	t1 = ktime_get();
> 	delta_us = ktime_us_delta(t1, t0);
> 
> use :
> 	struct skb_mstamp t0, t1;
> 
> 	skb_mstamp_get(&t0);
> 	// stuff
> 	skb_mstamp_get(&t1);
> 	delta_us = skb_mstamp_us_delta(&t1, &t0);
 ...
> +/**
> + * skb_mstamp_delta - compute the difference in usec between two skb_mstamp
> + * @t1: pointer to oldest sample
> + * @t0: pointer to newest sample
> + */
> +static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
> +				      const struct skb_mstamp *t0)

Maybe your definition of "newest" is different from mine, to me it
means most recently sampled.  And if so, your t1 and t0 descriptions
seem reversed.

Please fix this and resubmit with Neal's ACK etc.

Thanks!
