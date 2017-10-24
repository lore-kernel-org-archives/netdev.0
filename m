From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Tue, 24 Oct 2017 17:47:22 +0900 (KST)
Message-ID: <20171024.174722.1655125725592115397.davem@davemloft.net>
References: <20171023181857.GA25379@embeddedor.com>
        <20171024032508.GC28462@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: garsilva@embeddedor.com, steffen.klassert@secunet.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024032508.GC28462@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Oct 2017 11:25:08 +0800

> On Mon, Oct 23, 2017 at 01:18:57PM -0500, Gustavo A. R. Silva wrote:
>> Use BUG_ON instead of if condition followed by BUG.
>> 
>> This issue was detected with the help of Coccinelle.
>> 
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> 
> I think this patch is terrible.  Why on earth is Coccinelle even
> warning about this?

BUG_ON(x) generates significantly better code than
"if (cond) BUG();" because it's not possible to emit
the most optimal code sequences like on powerpc that has
conditional traps.

That's why.

I'm applying these transformations all over the networking as I
receive them and I advise that you do so for crypto as well.

Thank.
