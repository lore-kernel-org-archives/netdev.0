From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 20:18:19 +1000
Message-ID: <20080821101819.GA3700@gondor.apana.org.au>
References: <20080819073558.GD4376@ff.dom.local> <20080819074606.GA5261@gondor.apana.org.au> <20080819075623.GE4376@ff.dom.local> <20080819080557.GA17977@gondor.apana.org.au> <20080819081713.GF4376@ff.dom.local> <20080819082355.GA28869@gondor.apana.org.au> <20080819083909.GG4376@ff.dom.local> <20080819085504.GB29038@gondor.apana.org.au> <20080819091642.GI4376@ff.dom.local> <20080821100155.GA3621@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60617 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751101AbYHUKSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 06:18:32 -0400
Content-Disposition: inline
In-Reply-To: <20080821100155.GA3621@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 10:01:55AM +0000, Jarek Poplawski wrote:
> 
> But how about this part in qdisc_destroy(): 
>         if (qdisc->parent)
>                 list_del(&qdisc->list);

This list should only be used by things like qdisc_lookup which
occurs under the RTNL.  The actual packet processing certainly
should not be walking a linked list.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
