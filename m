From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 02/10] net: sched: introduce tcf block
 infractructure
Date: Tue, 16 May 2017 22:57:46 +0200
Message-ID: <20170516205746.GQ1939@nanopsycho.orion>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172802.1317-3-jiri@resnulli.us>
 <CAM_iQpW1wsvyg_v2Vy9Bg33f5iT9_c8kNdgn+0CXkAbVCs8=ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34590 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752258AbdEPU5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:57:49 -0400
Received: by mail-wr0-f196.google.com with SMTP id 6so15362788wrb.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:57:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpW1wsvyg_v2Vy9Bg33f5iT9_c8kNdgn+0CXkAbVCs8=ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 16, 2017 at 10:51:30PM CEST, xiyou.wangcong@gmail.com wrote:
>On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
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
>XXX_get() is usually for refcnt'ing, here you only allocate
>a block, so please rename it to tcf_block_alloc().

I already replied to the same Jamal's comment.


>
>
>> +
>> +void tcf_block_put(struct tcf_block *block)
>> +{
>> +       if (!block)
>> +               return;
>> +       tcf_destroy_chain(block->p_filter_chain);
>> +       kfree(block);
>> +}
>> +EXPORT_SYMBOL(tcf_block_put);
>
>Ditto, tcf_block_destroy().
