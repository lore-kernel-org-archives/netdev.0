From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] XFRM: Fix memory leak in xfrm_state_update
Date: Fri, 08 Jul 2011 08:59:11 -0700 (PDT)
Message-ID: <20110708.085911.284201104178395050.davem@davemloft.net>
References: <alpine.LFD.1.10.1107071820060.7677@net-test1.az.mvista.com>
	<20110708030032.GA25702@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgohad@mvista.com, netdev@vger.kernel.org, tusharsg@gmail.com
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab1GHP7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 11:59:22 -0400
In-Reply-To: <20110708030032.GA25702@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Fri, 8 Jul 2011 11:00:32 +0800

> On Thu, Jul 07, 2011 at 06:38:52PM -0700, Tushar Gohad wrote:
>>
>> Upon "ip xfrm state update ..", xfrm_add_sa() takes an extra reference on 
>> the user-supplied SA and forgets to drop the reference when  
>> xfrm_state_update() returns 0.  This leads to a memory leak as the  
>> parameter SA is never freed.  This change attempts to fix the leak by  
>> calling __xfrm_state_put() when xfrm_state_update() updates a valid SA  
>> (err = 0).  The parameter SA is added to the gc list when the final  
>> reference is dropped by xfrm_add_sa() upon completion.
>>
>> Signed-off-by: Tushar Gohad <tgohad@mvista.com>
> 
> Ouch, thanks for catching this bug!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
