From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] neigh: Add missing rcu_assign_pointer
Date: Thu, 28 May 2015 21:50:44 +0800
Message-ID: <20150528135044.GA8313@gondor.apana.org.au>
References: <1432808028.24345.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ying.xue@windriver.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:33211 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbE1Nut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 09:50:49 -0400
Content-Disposition: inline
In-Reply-To: <1432808028.24345.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> This patch is not needed.
> 
> You really should read Documentation/RCU , because it looks like you are
> quite confused.
> 
> When we remove an element from a RCU protected list, all the objects in
> the chain are already ready to be caught by rcu readers.
> 
> Therefore, no additional memory barrier is needed before doing *np =
> n->next;
> 
> Please do not add spurious memory barriers. Like atomic operations, we
> want all of them being required and possibly documented.

This patch is indeed bogus but accessing an RCU-protected like
this will trigger sparse warnings.  So better make it an
RCU_INIT_POINTER.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
