From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 06 Sep 2016 07:30:44 -0700
Message-ID: <1473172244.10725.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473169060-29651-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36480 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755636AbcIFOaq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 10:30:46 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so11033628pab.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 07:30:46 -0700 (PDT)
In-Reply-To: <1473169060-29651-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-06 at 09:37 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> +
> +struct tcf_skbmod_params {
> +	struct rcu_head	rcu;
> +	u64	flags; /*up to 64 types of operations; extend if needed */
> +	u8	eth_dst[ETH_ALEN];
> +	u16	eth_type;
> +	u8	eth_src[ETH_ALEN];
> +};
> +
> +struct tcf_skbmod {
> +	struct tc_action	common;
> +	struct tcf_skbmod_params  *skbmod_p;

struct tcf_skbmod_params __rcu *skbmod_p;

> +};

Then add CONFIG_SPARSE_RCU_POINTER=y to your .config
And build/check

make C=2 M=net/sched

Thanks.
