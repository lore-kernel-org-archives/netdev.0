From: Simon Horman <horms@verge.net.au>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 30 Aug 2010 12:29:39 +0900
Message-ID: <20100830032935.GA18072@verge.net.au>
References: <20100830130453.d810b086.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100830130453.d810b086.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 30, 2010 at 01:04:53PM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_nat_icmp_v6':
> net/netfilter/ipvs/ip_vs_core.c:640: error: implicit declaration of function 'csum_ipv6_magic'
> 
> Caused by commit 8870f8427b8fe30b2684b9e569e5ce038faf41ac ("IPVS: ICMPv6
> checksum calculation").  I added the following patch:
> [I think we have seen this before :-(]
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 30 Aug 2010 13:01:20 +1000
> Subject: [PATCH] IPVS: include net/ip6_checksum.h for csum_ipv6_magic
> 
> Fixes this build error:
> 
> net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_nat_icmp_v6':
> net/netfilter/ipvs/ip_vs_core.c:640: error: implicit declaration of function 'csum_ipv6_magic'

Sorry about that, I didn't notice it because it doesn't show up on x86.

> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Simon Horman <horms@verge.net.au>

> ---
>  net/netfilter/ipvs/ip_vs_core.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 69661db..edbfb96 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -40,6 +40,7 @@
>  #include <net/udp.h>
>  #include <net/icmp.h>                   /* for icmp_send */
>  #include <net/route.h>
> +#include <net/ip6_checksum.h>
>  
>  #include <linux/netfilter.h>
>  #include <linux/netfilter_ipv4.h>
> -- 
> 1.7.1
> 
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> http://www.canb.auug.org.au/~sfr/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
