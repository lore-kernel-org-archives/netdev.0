From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/9] net: core: use this_cpu_ptr per-cpu helper
Date: Fri, 2 Nov 2012 17:44:55 +0000
Message-ID: <0000013ac239c004-87f4c3e0-5c6a-4979-817f-0a0c4445a4e9-000000@email.amazonses.com>
References: <5093EE47.20700@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	steffen.klassert@secunet.com, NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5093EE47.20700@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 3 Nov 2012, Shan Wei wrote:
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
> +	tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet

Another case for the use of this_cpu_read
