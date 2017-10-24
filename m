From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Tue, 24 Oct 2017 17:48:42 +0900 (KST)
Message-ID: <20171024.174842.272234711073180328.davem@davemloft.net>
References: <20171024032508.GC28462@gondor.apana.org.au>
        <20171023225043.Horde.R0FvJkHEmPPjnRNzKMOrPb3@gator4166.hostgator.com>
        <20171024035320.GA29795@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: garsilva@embeddedor.com, steffen.klassert@secunet.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024035320.GA29795@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Oct 2017 11:53:20 +0800

> No your patch makes it worse.  The original construct makes it
> clear that the conditional is real code and not just some debugging
> aid.
> 
> With your patch, real code is now inside BUG_ON.

This discussion has happened before.

But I'll explain the conclusion here for your benefit.

BUG_ON() is a statement and everything inside of it will
always execute.

BUG_ON() is always preferred because it allows arch
specific code to pass the conditional result properly
into inline asm and builtins for optimal code generation.
