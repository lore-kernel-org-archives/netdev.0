From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: core: Quiet W=1 warnings for unused vars
 and static functions
Date: Mon, 06 Oct 2014 15:02:19 -0700
Message-ID: <1412632939.11091.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412632298.2916.42.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412632298.2916.42.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-10-06 at 14:51 -0700, Joe Perches wrote:
> Reduce noise when compiling W=1.
> 
> All the variables are unused.
> The functions are not called outside of the file so static
> is preferred.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> John, can you please verify that these gen_stats accesses
> are unnecessary?  I believe the compiler can elide them in
> any case, but I'm not sure what you intended here.

...

> diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
> index 14681b9..01be9cf 100644
> --- a/net/core/gen_stats.c
> +++ b/net/core/gen_stats.c
> @@ -106,13 +106,9 @@ __gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
>  	for_each_possible_cpu(i) {
>  		struct gnet_stats_basic_cpu *bcpu = per_cpu_ptr(cpu, i);
>  		unsigned int start;
> -		__u64 bytes;
> -		__u32 packets;
>  
>  		do {
>  			start = u64_stats_fetch_begin_irq(&bcpu->syncp);
> -			bytes = bcpu->bstats.bytes;
> -			packets = bcpu->bstats.packets;
>  		} while (u64_stats_fetch_retry_irq(&bcpu->syncp, start));
>  

Well... Please fix the bug for real.





>  		bstats->bytes += bcpu->bstats.bytes;

->

	bstats->bytes += bytes;
	bstats->packets += packets;
