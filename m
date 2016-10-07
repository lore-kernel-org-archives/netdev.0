From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Thu, 6 Oct 2016 17:44:42 -0700
Message-ID: <CAM_iQpXEgVfc1kKf5DyJM+Co6OProFQES-V0dyiC4BKiFgAzhA@mail.gmail.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
 <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
 <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com>
 <CAOrmypK=TZ=cDCDwy=wJgCsMgJWaMfr5dudEwHNnQzpeYJRfHw@mail.gmail.com>
 <CAM_iQpXB_LGd0GLmuyjcUqSvBy9nKX_02TEdm4GF3V-yX_rr0g@mail.gmail.com> <1475782699.28155.251.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33984 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754360AbcJGApD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:45:03 -0400
Received: by mail-it0-f66.google.com with SMTP id j69so157062itb.1
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 17:45:03 -0700 (PDT)
In-Reply-To: <1475782699.28155.251.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 6, 2016 at 12:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> And another quick grep shows that out of 142 drivers, only one [1] of
> them (incorrectly) checks netif_receive_skb() return value.
>

act_mirred is not a driver, apparently.


> Real question is more like : what is the impact of propagating an error
> at this point ?

_If_ we are going to just propagate the error like egress, then
the difference is m->tcf_action (PIPE or STOLEN) vs TC_ACT_SHOT.
And this error code is propagated from tcf_action_exec() up to
qdisc layer...
