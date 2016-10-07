From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Thu, 6 Oct 2016 17:49:16 -0700
Message-ID: <CAM_iQpUSbqnho97XufnFW=jJmCnc8HXbz657rk=LZzxmf=hwDw@mail.gmail.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
 <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
 <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com>
 <CAOrmypK=TZ=cDCDwy=wJgCsMgJWaMfr5dudEwHNnQzpeYJRfHw@mail.gmail.com>
 <CAM_iQpXB_LGd0GLmuyjcUqSvBy9nKX_02TEdm4GF3V-yX_rr0g@mail.gmail.com> <2d606b1d-0281-403b-cf82-c02c785c0f10@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34268 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936356AbcJGAti (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:49:38 -0400
Received: by mail-io0-f176.google.com with SMTP id r30so32694472ioi.1
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 17:49:38 -0700 (PDT)
In-Reply-To: <2d606b1d-0281-403b-cf82-c02c785c0f10@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 6, 2016 at 5:17 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> I dont believe we need to bother with the return code in  this case.

Why?

For a quick example, STOLEN vs. SHOT:

        result = tc_classify(skb, filter, &res, false);
        if (result >= 0) {
#ifdef CONFIG_NET_CLS_ACT
                switch (result) {
                case TC_ACT_STOLEN:
                case TC_ACT_QUEUED:
                        *qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
                case TC_ACT_SHOT:
                        return 0;
                }
#endif

Note, *qerr is the return value to ->enqueue().
