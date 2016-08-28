From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Sun, 28 Aug 2016 09:07:47 -0700
Message-ID: <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33119 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755661AbcH1QHt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 12:07:49 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so7517193pac.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 09:07:49 -0700 (PDT)
In-Reply-To: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-08-28 at 08:19 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>

...

> +static int tcf_skbmod_run(struct sk_buff *skb, const struct tc_action *a,
> +			  struct tcf_result *res)
> +{
> +	struct tcf_skbmod *d = to_skbmod(a);
> +
> +	spin_lock(&d->tcf_lock);
> +	tcf_lastuse_update(&d->tcf_tm);
> +	bstats_update(&d->tcf_bstats, skb);
> +
> +	if (d->flags & SKBMOD_F_DMAC)
> +		ether_addr_copy(eth_hdr(skb)->h_dest, d->eth_dst);
> +	if (d->flags & SKBMOD_F_SMAC)
> +		ether_addr_copy(eth_hdr(skb)->h_source, d->eth_src);
> +	if (d->flags & SKBMOD_F_ETYPE)
> +		eth_hdr(skb)->h_proto = d->eth_type;
> +	if (d->flags & SKBMOD_F_SWAPMAC) {
> +		u8 tmpaddr[ETH_ALEN];
> +		/*XXX: I am sure we can come up with something more efficient */
> +		ether_addr_copy(tmpaddr, eth_hdr(skb)->h_dest);
> +		ether_addr_copy(eth_hdr(skb)->h_dest, eth_hdr(skb)->h_source);
> +		ether_addr_copy(eth_hdr(skb)->h_source, tmpaddr);
> +	}
> +
> +	spin_unlock(&d->tcf_lock);
> +	return d->tcf_action;
> +}


Adding an action with a spinlock held in fast path in 2016 is
a way to tell people : It is a toy, do not use it for real.

Sorry guys. Friends do not let friends do that anymore.

 
