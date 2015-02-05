From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] openvswitch: Initialize unmasked key and uid
 len
Date: Thu, 05 Feb 2015 10:37:17 -0800
Message-ID: <1423161437.31870.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423158984-1674-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Joe Stringer <joestringer@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:56254 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbbBEShU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:37:20 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so5970507igb.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:37:19 -0800 (PST)
In-Reply-To: <1423158984-1674-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-05 at 09:56 -0800, Pravin B Shelar wrote:
> Flow alloc needs to initialize unmasked key pointer. Otherwise
> it can crash kernel trying to free random unmasked-key pointer.

> CC: Joe Stringer <joestringer@nicira.com>
> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/openvswitch/flow_table.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
> index 5e57628..d58447d 100644
> --- a/net/openvswitch/flow_table.c
> +++ b/net/openvswitch/flow_table.c
> @@ -85,6 +85,8 @@ struct sw_flow *ovs_flow_alloc(void)
>  
>  	flow->sf_acts = NULL;
>  	flow->mask = NULL;
> +	flow->id.unmasked_key = NULL;
> +	flow->id.ufid_len = 0;
>  	flow->stats_last_writer = NUMA_NO_NODE;

At this stage, one has to wonder why not using kmem_cache_zalloc()
and reduce icache pressure right ?

And please please add :

Fixes: e64457191a259 ("openvswitch: Restructure datapath.c and flow.c")

or whatever commit was the bug origin.

Thanks
