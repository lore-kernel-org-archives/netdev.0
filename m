From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gro: make sure skb->cb[] initial content has not
 to be zero
Date: Fri, 16 May 2014 17:25:46 -0400 (EDT)
Message-ID: <20140516.172546.1197385833815835361.davem@davemloft.net>
References: <20140516203835.5941ea3f@vostro>
	<1400263479.5367.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<1400265277.5367.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, edumazet@google.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbaEPVZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 17:25:48 -0400
In-Reply-To: <1400265277.5367.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 May 2014 11:34:37 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Starting from linux-3.13, GRO attempts to build full size skbs.
> 
> Problem is the commit assumed one particular field in skb->cb[]
> was clean, but it is not the case on some stacked devices.
> 
> Timo reported a crash in case traffic is decrypted before
> reaching a GRE device.
> 
> Fix this by initializing NAPI_GRO_CB(skb)->last at the right place,
> this also removes one conditional.
> 
> Thanks a lot to Timo for providing full reports and bisecting this.
> 
> Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> Bisected-by: Timo Teras <timo.teras@iki.fi>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> Please Timo test this patch so that we confirm it fixes the bug for you.

Applied and queued up for -stable, thanks everyone.
