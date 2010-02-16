From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Tue, 16 Feb 2010 15:14:46 -0800 (PST)
Message-ID: <20100216.151446.66294061.davem@davemloft.net>
References: <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com>
	<20100215080846.GA18446@gondor.apana.org.au>
	<20100216060051.GA27804@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55491
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933495Ab0BPXOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:14:31 -0500
In-Reply-To: <20100216060051.GA27804@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 16 Feb 2010 14:00:51 +0800

> On Mon, Feb 15, 2010 at 04:08:46PM +0800, Herbert Xu wrote:
>>
>> Doh, I was looking at the buggy xfrm_state_clone path (which
>> incidently needs to be fixed to use xfrm_state_put).
> 
> Here's a fix for that problem.
> 
> xfrm: Fix xfrm_state_clone leak
> 
> xfrm_state_clone calls kfree instead of xfrm_state_put to free
> a failed state.  Depending on the state of the failed state, it
> can cause leaks to things like module references.
> 
> All states should be freed by xfrm_state_put past the point of
> xfrm_init_state.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6
