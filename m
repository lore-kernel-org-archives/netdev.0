From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Wed, 25 Oct 2017 13:22:22 +0900 (KST)
Message-ID: <20171025.132222.1438740282932861791.davem@davemloft.net>
References: <20171024035320.GA29795@gondor.apana.org.au>
        <20171024.174842.272234711073180328.davem@davemloft.net>
        <20171025040541.GA1999@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: garsilva@embeddedor.com, steffen.klassert@secunet.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025040541.GA1999@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 25 Oct 2017 12:05:41 +0800

> On Tue, Oct 24, 2017 at 05:48:42PM +0900, David Miller wrote:
>> 
>> This discussion has happened before.
>> 
>> But I'll explain the conclusion here for your benefit.
>> 
>> BUG_ON() is a statement and everything inside of it will
>> always execute.
>> 
>> BUG_ON() is always preferred because it allows arch
>> specific code to pass the conditional result properly
>> into inline asm and builtins for optimal code generation.
> 
> This is a good point.  However, while a little bit more verbose you
> can still achieve the same assembly-level result by something like
> 
> 	int err;
> 
> 	err = <insert real code here>;
> 	BUG_ON(err);
> 
> Having real code in BUG_ON may pose problems to people reading the
> code because some of us tend to ignore code in BUG_ON and similar
> macros such as BUILD_BUG_ON.

I agree that this makes the code easier to read and audit.
