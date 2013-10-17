From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Thu, 17 Oct 2013 19:04:20 +0800
Message-ID: <20131017110420.GA21027@gondor.apana.org.au>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
 <20131016123205.GA9982@gondor.apana.org.au>
 <20131017110149.GA6747@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49443 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752646Ab3JQLEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 07:04:35 -0400
Content-Disposition: inline
In-Reply-To: <20131017110149.GA6747@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 01:01:49PM +0200, Michal Kubecek wrote:
>
> When I was thinking about this, I came with two situations when this
> might IMHO happen:
> 
> 1. We are sending a packet to ourselves; this could mean not only a
> local loop but also e.g. a packets between an LXC container and the host
> or between two LXC containers. While it doesn't make much sense to use
> compression in such case, it might happen while testing a solution which
> is going to be used in a normal setup later.
> 
> 2. The packet was passed to tun/tap device by a userspace application.
> 
> Am I wrong?

I hope so :) Because otherwise xfrm_input will surely dead-lock since
it uses spin_lock.

The cases you mentioned should all go through netif_rx which will
then do the processing in BH context.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
