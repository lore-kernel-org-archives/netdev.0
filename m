From: David Miller <davem@davemloft.net>
Subject: Re: [xfrm_user] BUG: sleeping function called from invalid context
Date: Sat, 14 Aug 2010 22:38:30 -0700 (PDT)
Message-ID: <20100814.223830.200386282.davem@davemloft.net>
References: <20100812125027.GA12982@nb-core2.darkstar.lan>
	<20100813153658.GA27982@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kronos.it@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100813153658.GA27982@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 13 Aug 2010 11:36:58 -0400

> Luca Tettamanti <kronos.it@gmail.com> wrote:
>>
>> xfrm_user_policy takes read_lock(&xfrm_km_lock) before calling
>> xfrm_compile_policy (via km->compile_policy), which in turn calls
>> xfrm_policy_alloc with GFP_KERNEL.
> 
> Thanks for discovering this bug, it only took 8 years :)

We stumble over one of these every so often don't we? :)

> 
> xfrm: Use GFP_ATOMIC in xfrm_compile_policy
> 
> As xfrm_compile_policy runs within a read_lock, we cannot use
> GFP_KERNEL for memory allocations.
> 
> Reported-by: Luca Tettamanti <kronos.it@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
