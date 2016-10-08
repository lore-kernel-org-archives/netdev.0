From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sat, 8 Oct 2016 03:01:42 -0400
Message-ID: <4498612b-a8ad-7e4a-048b-483615a87a11@mojatatu.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
 <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
 <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com>
 <CAOrmypK=TZ=cDCDwy=wJgCsMgJWaMfr5dudEwHNnQzpeYJRfHw@mail.gmail.com>
 <CAM_iQpXB_LGd0GLmuyjcUqSvBy9nKX_02TEdm4GF3V-yX_rr0g@mail.gmail.com>
 <2d606b1d-0281-403b-cf82-c02c785c0f10@mojatatu.com>
 <CAM_iQpUSbqnho97XufnFW=jJmCnc8HXbz657rk=LZzxmf=hwDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33356 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935027AbcJHHBu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2016 03:01:50 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so3992067pfa.0
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2016 00:01:49 -0700 (PDT)
In-Reply-To: <CAM_iQpUSbqnho97XufnFW=jJmCnc8HXbz657rk=LZzxmf=hwDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-06 08:49 PM, Cong Wang wrote:
> On Thu, Oct 6, 2016 at 5:17 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> I dont believe we need to bother with the return code in  this case.
>
> Why?
>
> For a quick example, STOLEN vs. SHOT:
>
>         result = tc_classify(skb, filter, &res, false);
>         if (result >= 0) {
> #ifdef CONFIG_NET_CLS_ACT
>                 switch (result) {
>                 case TC_ACT_STOLEN:
>                 case TC_ACT_QUEUED:
>                         *qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
>                 case TC_ACT_SHOT:
>                         return 0;
>                 }
> #endif
>
> Note, *qerr is the return value to ->enqueue().
>

You are right. I take back what i said.
We at minimal need consistency; so whether going to ingress or egress
we should at least increment the overlimit stats in case of non-success
code. Shmulik please fix up with checks on return code.

cheers,
jamal
