From: David Miller <davem@davemloft.net>
Subject: Re: virtio_net: Fix napi poll list corruption
Date: Mon, 22 Dec 2014 16:10:49 -0500 (EST)
Message-ID: <20141222.161049.278043772767314122.davem@davemloft.net>
References: <1418756386-6940-1-git-send-email-david.vrabel@citrix.com>
	<20141220002327.GA31975@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, edumazet@google.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754868AbaLVVKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 16:10:52 -0500
In-Reply-To: <20141220002327.GA31975@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 20 Dec 2014 11:23:27 +1100

> The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
> interrupt masking in NAPI) breaks virtio_net in an insidious way.
> 
> It is now required that if the entire budget is consumed when poll
> returns, the napi poll_list must remain empty.  However, like some
> other drivers virtio_net tries to do a last-ditch check and if
> there is more work it will call napi_schedule and then immediately
> process some of this new work.  Should the entire budget be consumed
> while processing such new work then we will violate the new caller
> contract.
> 
> This patch fixes this by not touching any work when we reschedule
> in virtio_net.
> 
> The worst part of this bug is that the list corruption causes other
> napi users to be moved off-list.  In my case I was chasing a stall
> in IPsec (IPsec uses netif_rx) and I only belatedly realised that it
> was virtio_net which caused the stall even though the virtio_net
> poll was still functioning perfectly after IPsec stalled.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
