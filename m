From: David Miller <davem@davemloft.net>
Subject: Re: caif: Fix napi poll list corruption
Date: Mon, 22 Dec 2014 16:35:00 -0500 (EST)
Message-ID: <20141222.163500.2179428727234717734.davem@davemloft.net>
References: <20141220002327.GA31975@gondor.apana.org.au>
	<5497D3D9.2070509@redhat.com>
	<20141222093525.GA18616@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, david.vrabel@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716AbaLVVfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 16:35:03 -0500
In-Reply-To: <20141222093525.GA18616@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 22 Dec 2014 20:35:25 +1100

> The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
> interrupt masking in NAPI) breaks caif.
> 
> It is now required that if the entire budget is consumed when poll
> returns, the napi poll_list must remain empty.  However, like some
> other drivers caif tries to do a last-ditch check and if there is
> more work it will call napi_schedule and then immediately process
> some of this new work.  Should the entire budget be consumed while
> processing such new work then we will violate the new caller
> contract.
> 
> This patch fixes this by not touching any work when we reschedule
> in caif.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
