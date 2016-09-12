From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 16:20:04 -0700
Message-ID: <1473722404.18970.97.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
         <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
         <77bca669-9113-3977-ad3c-478091422ff8@mojatatu.com>
         <1473719192.18970.84.camel@edumazet-glaptop3.roam.corp.google.com>
         <3a1da0eb-b253-ef9c-8679-0290e670238c@mojatatu.com>
         <1473721837.18970.95.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34486 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750976AbcILXUG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:20:06 -0400
Received: by mail-pf0-f175.google.com with SMTP id p64so57084926pfb.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:20:06 -0700 (PDT)
In-Reply-To: <1473721837.18970.95.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 16:10 -0700, Eric Dumazet wrote:

> 
> diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
> index 508e051304fb62627e61b5065b2325edd1b84f2e..dc9dd8ae7d5405f76c775278dac7689655b21041 100644
> --- a/net/core/gen_stats.c
> +++ b/net/core/gen_stats.c
> @@ -142,10 +142,14 @@ __gnet_stats_copy_basic(const seqcount_t *running,
>  		return;
>  	}
>  	do {
> -		if (running)
> +		if (running) {
> +			local_bh_disable();
>  			seq = read_seqcount_begin(running);
> +		}
>  		bstats->bytes = b->bytes;
>  		bstats->packets = b->packets;
> +		if (running)
> +			local_bh_enable();
>  	} while (running && read_seqcount_retry(running, seq));
>  }

Ah well, forget this patch, re-enabling bh right before
read_seqcount_retry() is not going to help.
