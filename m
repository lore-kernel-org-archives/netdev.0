From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Fri, 23 Sep 2016 08:48:33 -0400
Message-ID: <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
 <20160923081106.73fb48df@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36429 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755454AbcIWMta (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 08:49:30 -0400
Received: by mail-it0-f66.google.com with SMTP id n143so952228ita.3
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 05:48:35 -0700 (PDT)
In-Reply-To: <20160923081106.73fb48df@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-23 01:11 AM, Shmulik Ladkani wrote:
> Hi,
>
> On Thu, 22 Sep 2016 19:40:15 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 16-09-22 09:21 AM, Shmulik Ladkani wrote:
>>> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>>>
>>> Up until now, 'action mirred' supported only egress actions (either
>>> TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).
>>>
>>> This patch implements the corresponding ingress actions
>>> TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.
>>>
>>> This allows attaching filters whose target is to hand matching skbs into
>>> the rx processing of a specified device.
>>
>> Thank you for doing this. There was something that made me remove
>> initial support for this feature - I am blanking out right now but
>> will find my notes and give more details.
>
> Thanks Jamal, appreciate any details.
>
> Was wondering why it's missing, googled a bit with no meaningful
> results, so speculated the following:
>
> Some time long ago, initial 'mirred' purpose was to facilitate ifb.
> Therefore 'egress redirect' was implemented. Jamal probably left the
> 'ingress' support for a later time :)
>

History is mirror/redirect were first introduced to do just those
plain vanilla-free features. IFB came later. Up until recently there
were still some bits to support the ingress features that were removed
by Florian W. to save some skb bits.


> One interesting usecase for 'ingress redirect' is creating "rx bouncing"
> construct (like macvlan/macvtap/ipvlan) but applied according to custom
> logic.
>

I thought that was the motivation as well.

>> It may be around preventing loops maybe.
>
> Could be, but personally, I treat these constructs as (powerful)
> building blocks, and "with great power comes great responsibility".
>

Amen.
I am a believer in let-the-user-shoot-their-big-toe-if-they-want.


> Even today, one may create loops using existing 'egress redirect',
> e.g. this rediculously errorneous construct:
>
>  # ip l add v0 type veth peer name v0p
>  # tc filter add dev v0p parent ffff: basic \
>     action mirred egress redirect dev v0
>

I think we actually recover from this one by eventually
dropping (theres a ttl field). We should at least not lock
the kernel forever.
The other question is what to set skb->dev and skb->iif?
Some information will be lost if you move around netdevs a
bit.

BTW: You have motivated me to start looking again at redirect
to socket that was also left out. I am getting tired of redirecting
to tuntap with all its bells and whistles.

cheers,
jamal
