From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skbuff: Add BUG_ON in skb_init.
Date: Wed, 09 Aug 2017 22:49:39 -0700 (PDT)
Message-ID: <20170809.224939.550080421760909361.davem@davemloft.net>
References: <1502280278-9970-1-git-send-email-xiangxia.m.yue@gmail.com>
        <1502280278-9970-2-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiangxia.m.yue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52000 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdHJFtk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:49:40 -0400
In-Reply-To: <1502280278-9970-2-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Date: Wed,  9 Aug 2017 05:04:38 -0700

> When initializing the skbuff SLAB cache, we should make
> sure it is successful. Adding BUG_ON to check it and
> init_inodecache() is in the same case.
> 
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> ---
>  net/core/skbuff.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 42b62c716a33..9513de519870 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3904,6 +3904,8 @@ void __init skb_init(void)
>  						0,
>  						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
>  						NULL);
> +	BUG_ON(skbuff_head_cache == NULL);
> +	BUG_ON(skbuff_fclone_cache == NULL);
>  }

I know you guys want every allocation to be explicitly checked so that
everything is consistent for static code analysis checkers.

But this is just wasted code.

The first allocation will take a NULL dereference and the backtrace
will make it completely clear which SLAB cache was NULL and couldn't
be allocated.

So there is no real value to adding these checks.

So I'm not applying this, sorry.

The same logic goes for your other patch of this nature.
