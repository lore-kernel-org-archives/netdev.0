From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Sat, 24 Sep 2016 17:07:12 -0700
Message-ID: <CAM_iQpU+7NDoGGPkkDHA=v5XW5z98GHQhstFg5H=WCyiBzA-eA@mail.gmail.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com> <20160923081106.73fb48df@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33125 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935087AbcIYAHd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 20:07:33 -0400
Received: by mail-io0-f193.google.com with SMTP id r145so9187091ior.0
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 17:07:33 -0700 (PDT)
In-Reply-To: <20160923081106.73fb48df@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2016 at 10:11 PM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> Was wondering why it's missing, googled a bit with no meaningful
> results, so speculated the following:
>
> Some time long ago, initial 'mirred' purpose was to facilitate ifb.
> Therefore 'egress redirect' was implemented. Jamal probably left the
> 'ingress' support for a later time :)
>
> One interesting usecase for 'ingress redirect' is creating "rx bouncing"
> construct (like macvlan/macvtap/ipvlan) but applied according to custom
> logic.

We have done this for our containers for a long time. We simply
redirect packets to veth TX then flow to veth RX of course.

One problem to use your code for us is that, the RX side of veth
is inside containers, not visible to outside, perhaps we need some
more parameter to tell the netns before the device name/index?
Thoughts?

>
>> It may be around preventing loops maybe.
>
> Could be, but personally, I treat these constructs as (powerful)
> building blocks, and "with great power comes great responsibility".
>
> Even today, one may create loops using existing 'egress redirect',
> e.g. this rediculously errorneous construct:
>
>  # ip l add v0 type veth peer name v0p
>  # tc filter add dev v0p parent ffff: basic \
>     action mirred egress redirect dev v0

Detecting such loops should not be hard technically, like we do
for reclassification. We might need some bits in skb to detect
this specific case. Anyway, I don't think it is a blocker, just need
more tests to catch some corner cases.

Thanks.
