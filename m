From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v3 02/10] net: sched: introduce tcf block infractructure
Date: Tue, 16 May 2017 15:34:04 -0700
Message-ID: <CAM_iQpUZKjR1SXVaHNq4fRiiFx8-X=mjK+k=4TDvxd5CuK4gyw@mail.gmail.com>
References: <20170516172802.1317-1-jiri@resnulli.us> <20170516172802.1317-3-jiri@resnulli.us>
 <CAM_iQpW1wsvyg_v2Vy9Bg33f5iT9_c8kNdgn+0CXkAbVCs8=ew@mail.gmail.com> <20170516.173404.1930033807247247443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34118 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdEPWe0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 18:34:26 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so41031665wmf.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 15:34:25 -0700 (PDT)
In-Reply-To: <20170516.173404.1930033807247247443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 2:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 16 May 2017 13:51:30 -0700
>
>> On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> +int tcf_block_get(struct tcf_block **p_block,
>>> +                 struct tcf_proto __rcu **p_filter_chain)
>>> +{
>>> +       struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
>>> +
>>> +       if (!block)
>>> +               return -ENOMEM;
>>> +       block->p_filter_chain = p_filter_chain;
>>> +       *p_block = block;
>>> +       return 0;
>>> +}
>>> +EXPORT_SYMBOL(tcf_block_get);
>>
>>
>> XXX_get() is usually for refcnt'ing, here you only allocate
>> a block, so please rename it to tcf_block_alloc().
>
> Later in the series he adds refcounting to these objects.
>
> He explained this to Jamal too.

I have read all patches, unless I miss something, block itself
is not refcn'ted, only chains are, so it makes no sense to get
a block, right?
