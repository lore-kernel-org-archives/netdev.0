From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 14:30:19 +1000
Message-ID: <E1KT803-00086Y-00@gondolin.me.apana.org.au>
References: <20080812.011510.20845920.davem@davemloft.net>
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58151 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750957AbYHMEaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 00:30:25 -0400
In-Reply-To: <20080812.011510.20845920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> The qdisc pointer traverses to the softirq handler, which can be run
> in a process context (via ksoftirqd), and this pointer gets there
> via the per-cpu ->output_queue.

Here are two possible solutions:

1) The active way: smp_call_function and forcibly remove the qdiscs
in question from each output_queue.

2) The passive way: Make dev_deactive call yield() until no qdisc's
are on an output_queue.  This assumes there is some sort of dead
flag detection on the output_queue side so it doesn't keep going
forever.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
