From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCHv3 net 3/3] net: cls_u32: catch all hardware offload errors
Date: Tue, 07 Jun 2016 15:38:24 -0700
Message-ID: <57574CE0.3060202@intel.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com> <1465337823-16096-1-git-send-email-jakub.kicinski@netronome.com> <1465337823-16096-4-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57193 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422669AbcFGWiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 18:38:25 -0400
In-Reply-To: <1465337823-16096-4-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/7/2016 3:17 PM, Jakub Kicinski wrote:
> Errors reported by u32_replace_hw_hnode() were not propagated.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> ---
> v3:
>   - new patch
Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>

>
>   net/sched/cls_u32.c | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 0fc1d47885f8..b9c3875fddc6 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -923,11 +923,17 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>   		ht->divisor = divisor;
>   		ht->handle = handle;
>   		ht->prio = tp->prio;
> +
> +		err = u32_replace_hw_hnode(tp, ht, flags);
> +		if (err) {
> +			kfree(ht);
> +			return err;
> +		}
> +
>   		RCU_INIT_POINTER(ht->next, tp_c->hlist);
>   		rcu_assign_pointer(tp_c->hlist, ht);
>   		*arg = (unsigned long)ht;
>   
> -		u32_replace_hw_hnode(tp, ht, flags);
>   		return 0;
>   	}
>   
