From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/9] net: core: use this_cpu_ptr per-cpu helper
Date: Wed, 31 Oct 2012 17:31:52 +0000
Message-ID: <0000013ab7e116c8-fac51ac3-c4a4-46b8-9d55-fb4df4019e30-000000@email.amazonses.com>
References: <509109E1.6040607@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	steffen.klassert@secunet.com, NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509109E1.6040607@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2012, Shan Wei wrote:

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
> +	tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet;
>  	tasklet->data = (unsigned long)info;
>  	tasklet_schedule(tasklet);
>  }
>

Reviewed-by: Christoph Lameter <cl@linux.com>
