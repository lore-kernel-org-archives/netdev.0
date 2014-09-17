From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [net-next PATCH] net: sched: cls_u32: rcu can not be last node
Date: Wed, 17 Sep 2014 07:54:05 +0200
Message-ID: <541921FD.1090203@hartkopp.net>
References: <20140917053434.2833.66129.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.219]:19326 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbaIQFyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 01:54:16 -0400
In-Reply-To: <20140917053434.2833.66129.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please add an appropriate comment to the *code* to prevent this knowledge to
disappear. No one will search/find this in git commit messages next time.

Tnx
Oliver

On 17.09.2014 07:34, John Fastabend wrote:
> tc_u32_sel 'sel' in tc_u_knode expects to be the last element in the
> structure and pads the structure with tc_u32_key fields for each key.
> 
>  kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL)
> 
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_u32.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index eceeb04..be24e7e 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -64,8 +64,8 @@ struct tc_u_knode {
>  	u32 __percpu		*pcpu_success;
>  #endif
>  	struct tcf_proto	*tp;
> -	struct tc_u32_sel	sel;
>  	struct rcu_head		rcu;
> +	struct tc_u32_sel	sel;
>  };
>  
>  struct tc_u_hnode {
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
