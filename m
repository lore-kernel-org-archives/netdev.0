From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Thu, 6 Oct 2016 20:17:05 -0400
Message-ID: <2d606b1d-0281-403b-cf82-c02c785c0f10@mojatatu.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
 <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
 <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com>
 <CAOrmypK=TZ=cDCDwy=wJgCsMgJWaMfr5dudEwHNnQzpeYJRfHw@mail.gmail.com>
 <CAM_iQpXB_LGd0GLmuyjcUqSvBy9nKX_02TEdm4GF3V-yX_rr0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33303 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbcJGARS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:17:18 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so1865774pfa.0
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 17:17:18 -0700 (PDT)
In-Reply-To: <CAM_iQpXB_LGd0GLmuyjcUqSvBy9nKX_02TEdm4GF3V-yX_rr0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-06 01:30 PM, Cong Wang wrote:
> On Thu, Oct 6, 2016 at 6:30 AM, Shmulik Ladkani
> <shmulik.ladkani@gmail.com> wrote:
>> Hi,
>>
>> On Mon, Oct 3, 2016 at 12:45 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Thu, Sep 29, 2016 at 4:03 AM, Shmulik Ladkani
>>> <shmulik.ladkani@gmail.com> wrote:
>>>>         skb2->skb_iif = skb->dev->ifindex;
>>>>         skb2->dev = dev;
>>>> -       err = dev_queue_xmit(skb2);
>>>> +       if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
>>>> +               err = dev_queue_xmit(skb2);
>>>> +       else
>>>> +               netif_receive_skb(skb2);
>>>
>>> Any reason why not check the return value here?
>>
>> Rationale: netif_receive_skb returns err if there was no protocol
>> handler to deliver the skb to.
>> If skb is not caught by any protocol handler, this should not be
>> considered an "ingress redirect" error. The redirect action should be
>> considered successful.
>

I dont believe we need to bother with the return code in  this case.
The core netif_receive_skb() code already increments any necessary
stats.

cheers,
jamal
