From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Mon, 26 Sep 2016 16:43:16 +0200
Message-ID: <54aa5404-f4c8-03e1-0b62-8c070bd6d65b@stressinduktion.org>
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
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: Florian Westphal <fw@strlen.de>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36676 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750754AbcIZOnT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 10:43:19 -0400
In-Reply-To: <20160926013504.GA1959@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.09.2016 03:35, Florian Westphal wrote:
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 16-09-25 02:31 PM, Florian Westphal wrote:
>>> Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
>>>> We can later address any loop-detection improvements in mirred.
>>>> WDYT?
>>>
>>> You can address this after fixing infamous spinlock recursion hard
>>> lockup (which has existed forever):
>>>
>>> tc qdisc add dev eth0 root handle 1: prio
>>> tc filter add dev eth0 parent 1: protocol ip u32 match u32 0 0 flowid
>>> 1:2 action mirred egress redirect dev eth0
>>>
>>> (only do this on toy vm)
>>>
>>
>> Realize didnt respond to this. Seems very simple to fix:
>> if skb->dev->ifindex and m->tcfm_dev->ifindex are the
>> same, then you can drop the packet.
> 
> Yes, but I think we get same issue when we deal with stacked
> interfaces, and redirect is to e.g. vlan on top of physical device.

We do have the adjacent upper lists in all netdevices, calculating if a
mirred actions would insert the skb on a stacked device above us should
be as easy as querying netdev_has_upper_dev and should be possible to
check that during config time.

> And we have such loops even without tc, for instance when placing
> both veth ends in same bridge :-(

We can't fix that without a ttl in the sk_buff struct.

Bye,
Hannes
