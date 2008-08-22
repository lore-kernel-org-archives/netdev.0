From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc list locking
Date: Fri, 22 Aug 2008 20:15:26 +1000
Message-ID: <20080822101526.GC14345@gondor.apana.org.au>
References: <20080821124834.GA8794@gondor.apana.org.au> <20080821204052.GB2665@ami.dom.local> <20080821222446.GF14521@gondor.apana.org.au> <20080822092729.GA14729@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44926 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753832AbYHVKPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 06:15:30 -0400
Content-Disposition: inline
In-Reply-To: <20080822092729.GA14729@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 09:27:30AM +0000, Jarek Poplawski wrote:
> 
> pkt_sched: Fix qdisc list locking
> 
> Since some qdiscs call qdisc_tree_decrease_qlen() (so qdisc_lookup())
> without rtnl_lock(), adding and deleting from a qdisc list needs
> additional locking. This patch adds global spinlock qdisc_list_lock
> and wrapper functions for modifying the list. It is considered as a
> temporary solution until hfsc_dequeue(), netem_dequeue() and
> tbf_dequeue() (or qdisc_tree_decrease_qlen()) are redone.
> 
> With feedback from Herbert Xu and David S. Miller.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

> +void qdisc_list_del(struct Qdisc *q)
> +{
> +	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {

Good catch! I'm not sure whether this would actually break but
it certainly makes me feel a lot better :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
