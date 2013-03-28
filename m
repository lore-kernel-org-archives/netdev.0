From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] core: fix the use of this_cpu_ptr
Date: Thu, 28 Mar 2013 06:05:33 -0700
Message-ID: <1364475933.15753.36.camel@edumazet-glaptop>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com, Shan Wei <davidshan@tencent.com>,
	Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:55528 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755479Ab3C1NFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 09:05:36 -0400
Received: by mail-da0-f42.google.com with SMTP id n15so4537934dad.29
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 06:05:35 -0700 (PDT)
In-Reply-To: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 17:42 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> flush_tasklet is not percpu var, and percpu is percpu var, and
> 	this_cpu_ptr(&info->cache->percpu->flush_tasklet)
> is not equal to
> 	&this_cpu_ptr(info->cache->percpu)->flush_tasklet
> 
> 1f743b076(use this_cpu_ptr per-cpu helper) introduced this bug.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/flow.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/flow.c b/net/core/flow.c
> index 7fae135..e8084b8 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -346,7 +346,7 @@ static void flow_cache_flush_per_cpu(void *data)
>  	struct flow_flush_info *info = data;
>  	struct tasklet_struct *tasklet;
>  
> -	tasklet = this_cpu_ptr(&info->cache->percpu->flush_tasklet);
> +	tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet;
>  	tasklet->data = (unsigned long)info;
>  	tasklet_schedule(tasklet);
>  }

Hi

Any reason you dont Cc Shan Wei & Christoph Lameter ?

Christoph, could this kind of error be detected by the compiler or
sparse ?

Thanks
