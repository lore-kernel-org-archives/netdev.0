From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sun, 25 Sep 2016 09:39:12 -0400
Message-ID: <bd2b555f-cba2-b7bc-1fbe-663da288d8a3@mojatatu.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
 <20160923081106.73fb48df@halley>
 <CAM_iQpU+7NDoGGPkkDHA=v5XW5z98GHQhstFg5H=WCyiBzA-eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36727 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034177AbcIYNjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 09:39:15 -0400
Received: by mail-it0-f65.google.com with SMTP id n143so3554227ita.3
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 06:39:14 -0700 (PDT)
In-Reply-To: <CAM_iQpU+7NDoGGPkkDHA=v5XW5z98GHQhstFg5H=WCyiBzA-eA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-24 08:07 PM, Cong Wang wrote:
> On Thu, Sep 22, 2016 at 10:11 PM, Shmulik Ladkani

>
> One problem to use your code for us is that, the RX side of veth
> is inside containers, not visible to outside, perhaps we need some
> more parameter to tell the netns before the device name/index?
> Thoughts?
>

Intriguing - but this would apply for only veth?

>>
>>> It may be around preventing loops maybe.
>>
>> Could be, but personally, I treat these constructs as (powerful)
>> building blocks, and "with great power comes great responsibility".
>>
>> Even today, one may create loops using existing 'egress redirect',
>> e.g. this rediculously errorneous construct:
>>
>>  # ip l add v0 type veth peer name v0p
>>  # tc filter add dev v0p parent ffff: basic \
>>     action mirred egress redirect dev v0
>
> Detecting such loops should not be hard technically, like we do
> for reclassification. We might need some bits in skb to detect
> this specific case.

Note my other email. We had the feature but we took it out to save bits
on the skb.


cheers,
jamal
