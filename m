From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2] net: sched: cls_u32: rcu can not be last
 node
Date: Wed, 17 Sep 2014 10:48:02 -0700
Message-ID: <1410976082.7106.239.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140917173108.3864.57490.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:47690 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756423AbaIQRsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 13:48:04 -0400
Received: by mail-pd0-f173.google.com with SMTP id ft15so2599804pdb.4
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 10:48:04 -0700 (PDT)
In-Reply-To: <20140917173108.3864.57490.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-17 at 10:31 -0700, John Fastabend wrote:
> tc_u32_sel 'sel' in tc_u_knode expects to be the last element in the
> structure and pads the structure with tc_u32_key fields for each key.
> 
>  kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL)
> 
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_u32.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index eceeb04..8462132 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -64,8 +64,9 @@ struct tc_u_knode {
>  	u32 __percpu		*pcpu_success;
>  #endif
>  	struct tcf_proto	*tp;
> -	struct tc_u32_sel	sel;
>  	struct rcu_head		rcu;
> +	struct tc_u32_sel	sel;
> +	/* tc_u32_keys allocated at end of structure */
>  };
>  
>  struct tc_u_hnode {

Sorry to be picky, but comment should be before 'sel' or at same line.

It should mention that 'sel' MUST be last field.

Thanks !
