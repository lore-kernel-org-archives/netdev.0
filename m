From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] xfrm: Fix unlink race when policies are deleted.
Date: Thu, 27 Feb 2014 14:27:12 +0800
Message-ID: <20140227062712.GA31082@gondor.apana.org.au>
References: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
 <1393481799-20492-6-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:32873 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbaB0G1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 01:27:54 -0500
Content-Disposition: inline
In-Reply-To: <1393481799-20492-6-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 27, 2014 at 07:16:39AM +0100, Steffen Klassert wrote:
> When a policy is unlinked from the lists in thread context,
> the xfrm timer can fire before we can mark this policy as dead.
> So reinitialize the bydst hlist, then hlist_unhashed() will
> notice that this policy is not linked and will avoid a
> doulble unlink of that policy.
> 
> Reported-by: Xianpeng Zhao <673321875@qq.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

If this race condition is real then I don't see how this fix
can be correct since there aren't any barriers between the check
and the unlink.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
