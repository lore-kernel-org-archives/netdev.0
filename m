From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] core: simplify the getting percpu of flow_cache
Date: Thu, 28 Mar 2013 06:15:27 -0700
Message-ID: <1364476527.15753.38.camel@edumazet-glaptop>
References: <1364473451-3640-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christoph Lameter <cl@linux.com>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:60882 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755980Ab3C1NPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 09:15:30 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so972074pdj.13
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 06:15:29 -0700 (PDT)
In-Reply-To: <1364473451-3640-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 20:24 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> replace per_cpu with per_cpu_ptr to save conversion between address and pointer
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/flow.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/flow.c b/net/core/flow.c
> index 7fae135..707fb7b 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -334,7 +334,7 @@ static int flow_cache_percpu_empty(struct flow_cache *fc, int cpu)
>  	struct flow_cache_percpu *fcp;
>  	int i;
>  
> -	fcp = &per_cpu(*fc->percpu, cpu);
> +	fcp = per_cpu_ptr(fc->percpu, cpu);
>  	for (i = 0; i < flow_cache_hash_size(fc); i++)
>  		if (!hlist_empty(&fcp->hash_table[i]))
>  			return 0;


This makes no difference at all, at least on x86

Care to elaborate ?
