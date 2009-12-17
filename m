From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 14:28:53 +0800
Message-ID: <20091217062853.GA27734@gondor.apana.org.au>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au> <20091216025331.GA13935@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au> <1261014180.11648.35.camel@w-sridhar.beaverton.ibm.com> <20091217031539.GA26087@gondor.apana.org.au> <4B29BC1C.7090800@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47660 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754821AbZLQG3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 01:29:04 -0500
Content-Disposition: inline
In-Reply-To: <4B29BC1C.7090800@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 09:05:32PM -0800, Sridhar Samudrala wrote:
>
> I think sch_direct_xmit() is not even calling dev_hard_start_xmit() as  
> the tx queue is stopped
> and does a dev_requeue_skb() and returns NETDEV_TX_BUSY.

Yes but if the queue was stopped then we shouldn't even get into
sch_direct_xmit.  While inside sch_direct_xmit, then only way for
the queue to be stopped is through dev_hard_start_xmit, and when
that happens sch_direct_xmit will exit so we should never see a
requeue if the driver is working properly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
