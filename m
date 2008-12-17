From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 15:21:18 -0800 (PST)
Message-ID: <20081217.152118.103503644.davem@davemloft.net>
References: <20081217212907.GA27243@gondor.apana.org.au>
	<20081217225231.GA28052@gondor.apana.org.au>
	<20081217231543.GA28459@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, ptesarik@suse.cz, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751496AbYLQXVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:21:17 -0500
In-Reply-To: <20081217231543.GA28459@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 18 Dec 2008 10:15:43 +1100

> +		if (between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF)) {
> +			th->urg_ptr = htons(tp->snd_up - tcb->seq);
> +			th->urg = 1;
> +		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
> +			th->urg_ptr = 0xFFFF;
> +			th->urg = 1;
> +		}

What does this make happen for a jumbo frame where the urgent pointer
is within this packet, yet is beyond the 0xffff offset limit?

I think this can't be used.

