From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Thu, 6 Oct 2016 06:30:35 -0700
Message-ID: <CAOrmypK=TZ=cDCDwy=wJgCsMgJWaMfr5dudEwHNnQzpeYJRfHw@mail.gmail.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
 <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com> <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:33677 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbcJFNah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 09:30:37 -0400
Received: by mail-vk0-f66.google.com with SMTP id z126so751772vkd.0
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 06:30:36 -0700 (PDT)
In-Reply-To: <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Oct 3, 2016 at 12:45 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Sep 29, 2016 at 4:03 AM, Shmulik Ladkani
> <shmulik.ladkani@gmail.com> wrote:
>>         skb2->skb_iif = skb->dev->ifindex;
>>         skb2->dev = dev;
>> -       err = dev_queue_xmit(skb2);
>> +       if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
>> +               err = dev_queue_xmit(skb2);
>> +       else
>> +               netif_receive_skb(skb2);
>
> Any reason why not check the return value here?

Rationale: netif_receive_skb returns err if there was no protocol
handler to deliver the skb to.
If skb is not caught by any protocol handler, this should not be
considered an "ingress redirect" error. The redirect action should be
considered successful.
