From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Sun, 10 Mar 2013 16:38:01 +0800
Message-ID: <20130310083800.GC10448@gondor.apana.org.au>
References: <1362540509.15793.158.camel@edumazet-glaptop>
 <20130305.233744.498353801662910535.davem@davemloft.net>
 <1362553398.15793.168.camel@edumazet-glaptop>
 <20130306.145947.1445904594058156164.davem@davemloft.net>
 <1362606777.15793.198.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eilong@broadcom.com, jhs@mojatatu.com,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:46047 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751590Ab3CJIiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 04:38:07 -0400
Content-Disposition: inline
In-Reply-To: <1362606777.15793.198.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 06, 2013 at 01:52:57PM -0800, Eric Dumazet wrote:
>
> - BQL (incurring more TX completion rounds and possibility to
> block/unblock a qdisc)
> - ticket spinlocks, and even with the guard of qdisc busylock
> 
> -> we can have a starvation problem.

This only happens in cases where we aren't using multiqueue or
we're using it incorrectly, resulting in TX work from being split
over CPUs.

In that case it's not clear that it is starvation if we keep the
TX processing on one CPU.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
