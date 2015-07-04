From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 3/6] net_sched: act: make tcfg_pval non zero
Date: Sat, 4 Jul 2015 09:18:53 +0200
Message-ID: <CANn89iJ9OWaG1_zvTMkGxpswGoGTweoi2XiYKoVVZcsLyn9w6A@mail.gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com>
	<1435842455-30501-4-git-send-email-edumazet@google.com>
	<559668A4.5040604@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37379 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbGEKzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 06:55:10 -0400
Received: by wicgi11 with SMTP id gi11so130368319wic.0
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 03:55:08 -0700 (PDT)
In-Reply-To: <559668A4.5040604@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks guys for the review.

For completeness, I'll add smp_wmb() here :

    gact->tcfg_pval    = max_t(u16, 1, p_parm->pval);
    smp_wmb();
    gact->tcfg_ptype   = p_parm->ptype;

And corresponding smp_rmb()

On Fri, Jul 3, 2015 at 12:49 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 07/02/15 09:07, Eric Dumazet wrote:
>>
>> First step for gact RCU operation :
>>
>> Instead of testing if tcfg_pval is zero or not, just make it 1.
>>
>> No change in behavior, but slightly faster code.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> cheers,
> jamal
>
