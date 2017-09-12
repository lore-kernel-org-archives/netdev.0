From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH] datapath: Fix an error handling path in
 'ovs_nla_init_match_and_action()'
Date: Tue, 12 Sep 2017 15:48:40 -0700
Message-ID: <c80dad4f-c4e1-de57-0534-bae017c3a8a8@gmail.com>
References: <20170911192015.17553-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        pshelar@nicira.com, davem@davemloft.net, xiangxia.m.yue@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170911192015.17553-1-christophe.jaillet@wanadoo.fr>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/11/2017 12:20 PM, Christophe JAILLET wrote:
> All other error handling paths in this function go through the 'error'
> label. This one should do the same.
> 
> Fixes: 9cc9a5cb176c ("datapath: Avoid using stack larger than 1024.")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> I think that the comment above the function could be improved. It looks
> like the commit log which has introduced this function.
> 
> I'm also not sure that commit 9cc9a5cb176c is of any help. It is
> supposed to remove a warning, and I guess it does. But 'ovs_nla_init_match_and_action()'
> is called unconditionnaly from 'ovs_flow_cmd_set()'. So even if the stack
> used by each function is reduced, the overall stack should be the same, if
> not larger.
> 
> So this commit sounds like adding a bug where the code was fine and states
> to fix an issue but, at the best, only hides it.

Having a large stack frame isn't really a bug per se.  But the Linux kernel
warns about stack frames that are too large so reordering the code to
get the warning to go away seems fine to me.

> 
> Instead of fixing the code with the proposed patch, reverting the initial
> commit could also be considered.

Then the warning will come back.

- Greg

> ---
>   net/openvswitch/datapath.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 76cf273a56c7..c3aec6227c91 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -1112,7 +1112,8 @@ static int ovs_nla_init_match_and_action(struct net *net,
>   		if (!a[OVS_FLOW_ATTR_KEY]) {
>   			OVS_NLERR(log,
>   				  "Flow key attribute not present in set flow.");
> -			return -EINVAL;
> +			error = -EINVAL;
> +			goto error;
>   		}
>   
>   		*acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], key,
> 
