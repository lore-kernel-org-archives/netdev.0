From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH] netfilter: xt_hashlimit: Add missing ULL suffixes for
 64-bit constants
Date: Thu, 6 Oct 2016 12:40:32 -0400
Message-ID: <57F67E80.7080303@akamai.com>
References: <1475761214-13387-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Joshua Hunt <johunt@akamai.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475761214-13387-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2016 09:40 AM, Geert Uytterhoeven wrote:
> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
> index 2fab0c65aa94b666..b89b688e9d01a2d1 100644
> --- a/net/netfilter/xt_hashlimit.c
> +++ b/net/netfilter/xt_hashlimit.c
> @@ -431,7 +431,7 @@ static void htable_put(struct xt_hashlimit_htable *hinfo)
>     CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32 ie.
>  */
>  #define MAX_CPJ_v1 (0xFFFFFFFF / (HZ*60*60*24))
> -#define MAX_CPJ (0xFFFFFFFFFFFFFFFF / (HZ*60*60*24))
> +#define MAX_CPJ (0xFFFFFFFFFFFFFFFFULL / (HZ*60*60*24))
>  
>  /* Repeated shift and or gives us all 1s, final shift and add 1 gives
>   * us the power of 2 below the theoretical max, so GCC simply does a
> @@ -473,7 +473,7 @@ static u64 user2credits(u64 user, int revision)
>  		return div64_u64(user * HZ * CREDITS_PER_JIFFY_v1,
>  				 XT_HASHLIMIT_SCALE);
>  	} else {
> -		if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
> +		if (user > 0xFFFFFFFFFFFFFFFFULL / (HZ*CREDITS_PER_JIFFY))
>  			return div64_u64(user, XT_HASHLIMIT_SCALE_v2)
>  				* HZ * CREDITS_PER_JIFFY;
>  
> -- 1.9.1

Thanks for fixing this.

Acked-by: Vishwanath Pai <vpai@akamai.com>
