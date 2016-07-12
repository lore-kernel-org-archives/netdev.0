From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: 4.6.3, pppoe + shaper workload, skb_panic / skb_push / ppp_start_xmit
Date: Tue, 12 Jul 2016 11:05:41 -0700
Message-ID: <CAM_iQpX65H3SasBCqBcu6qcH00OW3WjZgfWkq7=rrQzyBvKF9A@mail.gmail.com>
References: <c72d23549eaa7aadee1a66a6bb788a4a@nuclearcat.com>
 <CAM_iQpWuCw6Bgm=1BWMkoFkuav5xV+FyKPq0Ef+3N_qpQqv=AA@mail.gmail.com> <e9486191e8af136c9ed4cc1cfc26ac9f@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: nuclearcat@nuclearcat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33111 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbcGLSGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:06:01 -0400
Received: by mail-io0-f174.google.com with SMTP id 38so24027131iol.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 11:06:01 -0700 (PDT)
In-Reply-To: <e9486191e8af136c9ed4cc1cfc26ac9f@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 11:03 AM,  <nuclearcat@nuclearcat.com> wrote:
> On 2016-07-12 20:31, Cong Wang wrote:
>>
>> On Mon, Jul 11, 2016 at 12:45 PM,  <nuclearcat@nuclearcat.com> wrote:
>>>
>>> Hi
>>>
>>> On latest kernel i noticed kernel panic happening 1-2 times per day. It
>>> is
>>> also happening on older kernel (at least 4.5.3).
>>>
>> ...
>>>
>>>  [42916.426463] Call Trace:
>>>  [42916.426658]  <IRQ>
>>>
>>>  [42916.426719]  [<ffffffff81843786>] skb_push+0x36/0x37
>>>  [42916.427111]  [<ffffffffa00e8ce5>] ppp_start_xmit+0x10f/0x150
>>> [ppp_generic]
>>>  [42916.427314]  [<ffffffff81853467>] dev_hard_start_xmit+0x25a/0x2d3
>>>  [42916.427516]  [<ffffffff818530f2>] ?
>>> validate_xmit_skb.isra.107.part.108+0x11d/0x238
>>>  [42916.427858]  [<ffffffff8186dee3>] sch_direct_xmit+0x89/0x1b5
>>>  [42916.428060]  [<ffffffff8186e142>] __qdisc_run+0x133/0x170
>>>  [42916.428261]  [<ffffffff81850034>] net_tx_action+0xe3/0x148
>>>  [42916.428462]  [<ffffffff810c401a>] __do_softirq+0xb9/0x1a9
>>>  [42916.428663]  [<ffffffff810c4251>] irq_exit+0x37/0x7c
>>>  [42916.428862]  [<ffffffff8102b8f7>] smp_apic_timer_interrupt+0x3d/0x48
>>>  [42916.429063]  [<ffffffff818cb15c>] apic_timer_interrupt+0x7c/0x90
>>
>>
>> Interesting, we call a skb_cow_head() before skb_push() in
>> ppp_start_xmit(),
>> I have no idea why this could happen.
>>
>> Do you have any tc qdisc, filter or actions on this ppp device?
>
> Yes, i have policing filters for incoming traffic (ingress), and also on
> egress htb + pfifo + filters.

Does it make any difference if you remove the egress qdisc and/or
filters? If yes, please share the `tc qd show...` and `tc filter show ...`?

Thanks!
