From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 05/15] net: sched: cls_flow use RCU
Date: Tue, 09 Sep 2014 05:41:21 -0700
Message-ID: <1410266481.11872.158.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	 <20140909055601.2071.43459.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:48787 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756072AbaIIMlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 08:41:23 -0400
Received: by mail-pa0-f49.google.com with SMTP id lf10so3423749pab.36
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 05:41:22 -0700 (PDT)
In-Reply-To: <20140909055601.2071.43459.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 22:56 -0700, John Fastabend wrote:
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_flow.c |  145 +++++++++++++++++++++++++++++---------------------
>  1 file changed, 84 insertions(+), 61 deletions(-)
> 
> diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
> index 35be16f..e33560b 100644
> --- a/net/sched/cls_flow.c
> +++ b/net/sched/cls_flow.c
> @@ -34,12 +34,15 @@
>  
>  struct flow_head {
>  	struct list_head	filters;
> +	struct rcu_head		rcu;
>  };
>  
>  struct flow_filter {
>  	struct list_head	list;
> +	struct rcu_head		rcu;

Please move these 2 new fields at the end of structure, they are only
used at dismantle phase.

Patch looks fine otherwise, thanks !
