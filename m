From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH v4 1/9] net: core: use this_cpu_ptr per-cpu helper
Date: Fri, 16 Nov 2012 16:38:01 +0800
Message-ID: <50A5FB69.8000907@gmail.com>
References: <50A1A7BA.5000507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei88@gmail.com>, timo.teras@iki.fi,
	steffen.klassert@secunet.com, NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	cl@linux-foundation.org, Tejun Heo <htejun@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A1A7BA.5000507@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shan Wei said, at 2012/11/13 9:51:
> From: Shan Wei <davidshan@tencent.com>
> 
> flush_tasklet is a struct, not a pointer in percpu var.
> so use this_cpu_ptr to get the member pointer.
> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> Reviewed-by: Christoph Lameter <cl@linux.com>

David Miller,  would you like to pick it up to your net-next tree?

> ---
> no changes vs v3.
> ---
>  net/core/flow.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/flow.c b/net/core/flow.c
> index e318c7e..b0901ee 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -327,11 +327,9 @@ static void flow_cache_flush_tasklet(unsigned long data)
>  static void flow_cache_flush_per_cpu(void *data)
>  {
>  	struct flow_flush_info *info = data;
> -	int cpu;
>  	struct tasklet_struct *tasklet;
>  
> -	cpu = smp_processor_id();
> -	tasklet = &per_cpu_ptr(info->cache->percpu, cpu)->flush_tasklet;
> +	tasklet = this_cpu_ptr(&info->cache->percpu->flush_tasklet);
>  	tasklet->data = (unsigned long)info;
>  	tasklet_schedule(tasklet);
>  }
> 
