From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v2] openvswitch: Fix an error handling path in 'ovs_nla_init_match_and_action()'
Date: Mon, 11 Sep 2017 21:57:44 -0700
Message-ID: <CAOrHB_DfbU5PmH0Aos8T-j90PQEbaNkvR3TDJVv1kcJnVHVXrQ@mail.gmail.com>
References: <20170911195620.17931-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>,
        Tonghao Zhang <xiangxia.m.yue@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:51417 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdILE5s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 00:57:48 -0400
In-Reply-To: <20170911195620.17931-1-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 11, 2017 at 12:56 PM, Christophe JAILLET
<christophe.jaillet@wanadoo.fr> wrote:
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
It depends on which function stack depth are are looking at. for some
function it remains same. For nested function it goes down.

> So this commit sounds like adding a bug where the code was fine and states
> to fix an issue but, at the best, only hides it.
>
> Instead of fixing the code with the proposed patch, reverting the initial
> commit could also be considered.
>
> V2: update Subject line
> ---
>  net/openvswitch/datapath.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 76cf273a56c7..c3aec6227c91 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -1112,7 +1112,8 @@ static int ovs_nla_init_match_and_action(struct net *net,
>                 if (!a[OVS_FLOW_ATTR_KEY]) {
>                         OVS_NLERR(log,
>                                   "Flow key attribute not present in set flow.");
> -                       return -EINVAL;
> +                       error = -EINVAL;
> +                       goto error;
>                 }
>
Patch looks good to me.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
