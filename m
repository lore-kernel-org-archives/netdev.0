From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init()
 fails
Date: Fri, 24 Oct 2014 17:40:26 -0700
Message-ID: <1414197626.20845.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
	 <1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7N3jJCgOJjnDUxsTaH7ZCvPydDT60qkcqSPsEyFbp=UQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Wang Bo <wang.bo116@zte.com.cn>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Patrick McHardy <kaber@trash.net>, Terry Lam <vtlam@google.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:61387 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYAk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:40:28 -0400
Received: by mail-pd0-f175.google.com with SMTP id y13so2336380pdi.20
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:40:28 -0700 (PDT)
In-Reply-To: <CAHA+R7N3jJCgOJjnDUxsTaH7ZCvPydDT60qkcqSPsEyFbp=UQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-24 at 17:36 -0700, Cong Wang wrote:

> >>  static int multiq_dump(struct Qdisc *sch, struct sk_buff *skb)
> >> diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
> >> index 3ec7e88..55ac6a4 100644
> >> --- a/net/sched/sch_qfq.c
> >> +++ b/net/sched/sch_qfq.c
> >> @@ -522,7 +522,6 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
> >>       return 0;
> >>
> >>  destroy_class:
> >> -     qdisc_destroy(cl->qdisc);
> >>       kfree(cl);
> >>       return err;
> >>  }
> >
> >
> > Really ? I am calling this a leak of cl->qdisc.
> >
> >
> 
> How? I already added a comment on qdisc_create_dflt(), callers don't
> need to clean up
> on failure path.

Seriously, can you read the function again ?

What happens if gen_new_estimator() fails ?
