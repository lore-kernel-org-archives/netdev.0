From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Thu, 22 Dec 2011 02:01:59 -0500 (EST)
Message-ID: <20111222.020159.138601584172644611.davem@davemloft.net>
References: <20111222170726.b16565ef7d1434cc4ec170d7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	eric.dumazet@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111222170726.b16565ef7d1434cc4ec170d7@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 22 Dec 2011 17:07:26 +1100

> After merging the final tree, today's linux-next build (sparc32 defconfig)
> failed like this:
> 
> net/ipv4/route.c: In function 'rt_check_expire':
> net/ipv4/route.c:873:4: error: implicit declaration of function 'prefetch' [-Werror=implicit-function-declaration]
> 
> Caused by commit 9f28a2fc0bd7 ("ipv4: reintroduce route cache garbage
> collector").
> 
> Linus, that commit is in the latest pull request you have from Dave ...

Sorry, that was just reinstating code that got removed but we forgot
the prefetch.h header.  Both Eric and I test built this as well as did
run time testing on the fix.

Linus, could you just apply this obvious fix directly?  Sorry for the
trouble.

Thanks.

> I applied the following patch for today:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 22 Dec 2011 17:03:29 +1100
> Subject: [PATCH] ipv4: using prefetch requires including prefetch.h
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  net/ipv4/route.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 7460483..9c01f56 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -91,6 +91,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/times.h>
>  #include <linux/slab.h>
> +#include <linux/prefetch.h>
>  #include <net/dst.h>
>  #include <net/net_namespace.h>
>  #include <net/protocol.h>
> -- 
> 1.7.8.197.g73c6b
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> http://www.canb.auug.org.au/~sfr/
