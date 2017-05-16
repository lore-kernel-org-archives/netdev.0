From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v3 02/10] net: sched: introduce tcf block infractructure
Date: Tue, 16 May 2017 13:51:30 -0700
Message-ID: <CAM_iQpW1wsvyg_v2Vy9Bg33f5iT9_c8kNdgn+0CXkAbVCs8=ew@mail.gmail.com>
References: <20170516172802.1317-1-jiri@resnulli.us> <20170516172802.1317-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36610 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdEPUvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:51:51 -0400
Received: by mail-wm0-f65.google.com with SMTP id u65so39879485wmu.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:51:51 -0700 (PDT)
In-Reply-To: <20170516172802.1317-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> +int tcf_block_get(struct tcf_block **p_block,
> +                 struct tcf_proto __rcu **p_filter_chain)
> +{
> +       struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
> +
> +       if (!block)
> +               return -ENOMEM;
> +       block->p_filter_chain = p_filter_chain;
> +       *p_block = block;
> +       return 0;
> +}
> +EXPORT_SYMBOL(tcf_block_get);


XXX_get() is usually for refcnt'ing, here you only allocate
a block, so please rename it to tcf_block_alloc().


> +
> +void tcf_block_put(struct tcf_block *block)
> +{
> +       if (!block)
> +               return;
> +       tcf_destroy_chain(block->p_filter_chain);
> +       kfree(block);
> +}
> +EXPORT_SYMBOL(tcf_block_put);

Ditto, tcf_block_destroy().
