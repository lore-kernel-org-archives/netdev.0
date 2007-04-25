From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Wed, 25 Apr 2007 11:06:27 +1000
Message-ID: <E1HgVxj-0003U6-00@gondolin.me.apana.org.au>
References: <20070424.142008.35506725.davem@davemloft.net>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1411 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754669AbXDYBGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 21:06:38 -0400
In-Reply-To: <20070424.142008.35506725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> Is it illegal to sleep with a mutex held?

Shouldn't be.
 
> I think I see what might be the problem, nlk->cb_mutex is set
> to "rtnl_mutex" and this is used for other purposes in various
> code paths here, maybe there is a double mutex_unlock() or
> similar due to that?

Indeed, the RTNL is held during the processing of all RTNETLINK
messages so we'd be trying to lock it recursively here which is
not allowed.

Actually I'm not quite sure what the benefit is for allowing an
override CB mutex.  Since we still have to take it and we always
allocate memory for a mutex anyway this would seem to be strictly
worse than just using our own mutex.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
