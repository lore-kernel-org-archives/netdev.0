From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] openvswitch: Zero flows on allocation.
Date: Sun, 20 Sep 2015 09:32:27 -0700
Message-ID: <1442766747.29850.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442628374-57025-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35735 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbbITQca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 12:32:30 -0400
Received: by pacfv12 with SMTP id fv12so96076816pac.2
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 09:32:29 -0700 (PDT)
In-Reply-To: <1442628374-57025-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-18 at 19:06 -0700, Jesse Gross wrote:

> 
> Fixes: 07148121 ("openvswitch: Eliminate memset() from flow_extract.")
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  net/openvswitch/flow_table.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
> index d22d8e9..5248322 100644
> --- a/net/openvswitch/flow_table.c
> +++ b/net/openvswitch/flow_table.c
> @@ -80,7 +80,7 @@ struct sw_flow *ovs_flow_alloc(void)
>  	struct flow_stats *stats;
>  	int node;
>  
> -	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
> +	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL | __GFP_ZERO);

Or kmem_cache_zalloc(flow_cache, GFP_KERNEL) ?
