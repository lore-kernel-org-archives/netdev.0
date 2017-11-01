From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 2/2] net: core: introduce mini_Qdisc and
 eliminate usage of tp->q for clsact fastpath
Date: Wed, 1 Nov 2017 11:30:52 +0100
Message-ID: <20171101103052.GE1977@nanopsycho.orion>
References: <20171031151222.5021-1-jiri@resnulli.us>
 <20171031151222.5021-3-jiri@resnulli.us>
 <20171101021248.624bvt5jcqr37w5e@ast-mbp>
 <59F9A0FE.2040608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, edumazet@google.com,
        alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:55662 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdKAKay (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 06:30:54 -0400
Received: by mail-wr0-f194.google.com with SMTP id l8so1522205wre.12
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 03:30:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <59F9A0FE.2040608@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 01, 2017 at 11:25:02AM CET, daniel@iogearbox.net wrote:
>On 11/01/2017 03:12 AM, Alexei Starovoitov wrote:
>> On Tue, Oct 31, 2017 at 04:12:22PM +0100, Jiri Pirko wrote:
>> > From: Jiri Pirko <jiri@mellanox.com>
>[...]
>> I don't think it's great, but I don't have any suggestions on
>> how to avoid it, so I'm not objecting. Just disappointed that
>> you keep adding stuff to tc and messing with sw fast path only to
>> make parity with some obscure hw feature.
>
>tc became a sink for that over time.

Block sharing is not only useful for offloads. But I understand.

>
>> If it keeps going like this we'd need to come up with some new fast
>> hook for clsbpf in ingress/egress paths. We use it for
>> every packet, so extra loads are not great.
>> I guess they should be cache hits, but will take extra cache line.
>> All of the bugs in tc logic recently are not comforting either.
>
>+1

I don't see any effect of tc changes on clsbpf ingress/egress since
clsact was introduced. Could you point it out?
