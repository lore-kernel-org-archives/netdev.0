From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Wed, 16 Dec 2009 15:07:53 +1030
Message-ID: <200912161507.53805.rusty@rustcorp.com.au>
References: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com> <20091215144252.GA7465@gondor.apana.org.au> <20091215233226.GA27129@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40095 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761514AbZLPEh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 23:37:58 -0500
In-Reply-To: <20091215233226.GA27129@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Dec 2009 10:02:27 am Michael S. Tsirkin wrote:
> Right. Hmm. So for this to work we'll need to
> 1. Free skb upon interrupt instead of
>    waiting for the next xmit call
> 2. Add API to query free ring capacity
> 
> Rusty, sounds like a good plan?

Well, the query stuff is not too bad, but I can't completely convince myself
it's race-free.  We don't want to do locking.

A NAPI-style solution seems cleaner, and I'm testing that now.

> We could also extend host to delay interrupt
> until there is sufficient TX capacity
> but of course we also need to support
> old hosts as well.

Xen does this, and I rejected it in favor of simple enable/disable
flags in the original virtio design.  It was probably wrong: while the
guest can enable on a "few remaining" heuristic, it's going to have
latency.  The host can do a more timely decision.

There's nothing stopping the Host from doing this heuristic today, of
course: the DISABLE flag is advisory only.  But let's check the limitations
of the guest-enable approach first?

Thanks,
Rusty.
