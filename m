From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 02/10] net: sched: introduce tcf block
 infractructure
Date: Tue, 16 May 2017 17:34:04 -0400 (EDT)
Message-ID: <20170516.173404.1930033807247247443.davem@davemloft.net>
References: <20170516172802.1317-1-jiri@resnulli.us>
        <20170516172802.1317-3-jiri@resnulli.us>
        <CAM_iQpW1wsvyg_v2Vy9Bg33f5iT9_c8kNdgn+0CXkAbVCs8=ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jhs@mojatatu.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752311AbdEPVeJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:34:09 -0400
In-Reply-To: <CAM_iQpW1wsvyg_v2Vy9Bg33f5iT9_c8kNdgn+0CXkAbVCs8=ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 16 May 2017 13:51:30 -0700

> On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> +int tcf_block_get(struct tcf_block **p_block,
>> +                 struct tcf_proto __rcu **p_filter_chain)
>> +{
>> +       struct tcf_block *block = kzalloc(sizeof(*block), GFP_KERNEL);
>> +
>> +       if (!block)
>> +               return -ENOMEM;
>> +       block->p_filter_chain = p_filter_chain;
>> +       *p_block = block;
>> +       return 0;
>> +}
>> +EXPORT_SYMBOL(tcf_block_get);
> 
> 
> XXX_get() is usually for refcnt'ing, here you only allocate
> a block, so please rename it to tcf_block_alloc().

Later in the series he adds refcounting to these objects.

He explained this to Jamal too.
