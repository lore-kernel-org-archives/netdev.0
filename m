From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
Date: Thu, 21 Aug 2008 17:16:34 +1000
Message-ID: <20080821071634.GA1269@gondor.apana.org.au>
References: <20080819.040200.155911269.davem@davemloft.net> <20080819164830.GA2533@ami.dom.local> <20080819222329.GA10297@gondor.apana.org.au> <20080821054911.GA4178@ff.dom.local> <20080821061024.GA721@gondor.apana.org.au> <20080821064941.GA2764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60260 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753515AbYHUHQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 03:16:40 -0400
Content-Disposition: inline
In-Reply-To: <20080821064941.GA2764@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 06:49:41AM +0000, Jarek Poplawski wrote:
>
> We need to check if something depends on &noop_qdisc returned in the
> similar state. Otherwise, there is a bit too much possibilities here,
> so it would be nice to simplify this all.

Actually, why do we even keep a netdev_queue pointer in a qdisc?
A given qdisc can be used by multiple queues (which is why the
lock was moved into the qdisc in the first place).

How about keeping a pointer directly to the root qdisc plus a
pointer to the netdev (which seems to be the only other use for
qdisc->dev_queue)? That way there won't be any confusion as to
whether we want the sleeping or non-sleeping qdisc.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
