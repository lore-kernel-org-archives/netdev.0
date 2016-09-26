From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sun, 25 Sep 2016 21:40:55 -0400
Message-ID: <8a12cdce-aa06-4a5c-03c7-d832c30fe3f1@mojatatu.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
 <20160923081106.73fb48df@halley>
 <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
 <20160923184030.75124289@halley>
 <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
 <20160925203309.633cf3d5@halley> <20160925183136.GA3307@breakpoint.cc>
 <54535aa0-cafd-86ec-1f6c-64c974a5eed6@mojatatu.com>
 <20160926013504.GA1959@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33476 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936362AbcIZBk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 21:40:58 -0400
Received: by mail-it0-f68.google.com with SMTP id x192so4151812itb.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 18:40:57 -0700 (PDT)
In-Reply-To: <20160926013504.GA1959@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 09:35 PM, Florian Westphal wrote:
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>>
>> Realize didnt respond to this. Seems very simple to fix:
>> if skb->dev->ifindex and m->tcfm_dev->ifindex are the
>> same, then you can drop the packet.
>
> Yes, but I think we get same issue when we deal with stacked
> interfaces, and redirect is to e.g. vlan on top of physical device.
>
> And we have such loops even without tc, for instance when placing
> both veth ends in same bridge :-(


For egress->egress the xmit recursion should help (maybe an
audit needs to be done).
For the case Shmulik is trying to achieve I am not sure that
would help.
In general, catching such a loop (or broadcast), if cheap should
be attempted.

cheers,
jamal
