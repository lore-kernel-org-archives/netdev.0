From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next V2 1/6] net/sched: cls_matchall: Dump skip
 flags
Date: Tue, 14 Feb 2017 11:28:34 -0800
Message-ID: <20170214112834.3a5d9929@cakuba.netronome.com>
References: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
        <1487082640-24813-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:48561 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753949AbdBNT3C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 14:29:02 -0500
In-Reply-To: <1487082640-24813-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Feb 2017 16:30:35 +0200, Or Gerlitz wrote:
> The skip flags are not dumped to user-space, do that.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> Acked-by: Yotam Gigi <yotamg@mellanox.com>
> ---
>  net/sched/cls_matchall.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
> index f2141cb..ce2f7d4 100644
> --- a/net/sched/cls_matchall.c
> +++ b/net/sched/cls_matchall.c
> @@ -244,6 +244,8 @@ static int mall_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>  	    nla_put_u32(skb, TCA_MATCHALL_CLASSID, head->res.classid))
>  		goto nla_put_failure;
>  
> +	nla_put_u32(skb, TCA_MATCHALL_FLAGS, head->flags);
> +

Shouldn't the return status from nla_put_u32() be checked?
