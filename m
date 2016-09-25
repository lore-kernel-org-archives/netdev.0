From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Sat, 24 Sep 2016 17:20:07 -0700
Message-ID: <CAM_iQpUWto3520BKeJoW71Rjr69n06PBz_djsXzEYCM9E+93AA@mail.gmail.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com> <20160923081106.73fb48df@halley>
 <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com> <20160923184030.75124289@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36644 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932615AbcIYAU2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 20:20:28 -0400
Received: by mail-io0-f193.google.com with SMTP id z135so9212484ioe.3
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 17:20:28 -0700 (PDT)
In-Reply-To: <20160923184030.75124289@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 8:40 AM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> On Fri, 23 Sep 2016 08:48:33 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> > Even today, one may create loops using existing 'egress redirect',
>> > e.g. this rediculously errorneous construct:
>> >
>> >  # ip l add v0 type veth peer name v0p
>> >  # tc filter add dev v0p parent ffff: basic \
>> >     action mirred egress redirect dev v0
>>
>> I think we actually recover from this one by eventually
>> dropping (theres a ttl field).
>
> [off topic]
>
> Don't know about that :) cpu fan got very noisy, 3 of 4 cores at 100%,
> and after one second I got:
>
> # ip -s l show type veth
> 16: v0p@v0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
>     link/ether a2:64:ff:10:dd:85 brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     71660305923 469890864 0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     3509       24       0       0       0       0
> 17: v0@v0p: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
>     link/ether 52:a2:34:f6:7c:ec brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     3509       24       0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     71660713017 469893555 0       0       0       0

These ghost packets never enter IP stack, I don't think TTL
helps.
