From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: increase drops and decrease backlog
 when packets are dropped
Date: Wed, 07 May 2014 19:55:01 -0700
Message-ID: <1399517701.15399.165.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399369056-1632-1-git-send-email-yangyingliang@huawei.com>
	 <1399384701.15399.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <536AE70F.7060307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vtlam@google.com, nanditad@google.com,
	davem@davemloft.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:37478 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbaEHCzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 22:55:04 -0400
Received: by mail-pd0-f176.google.com with SMTP id y13so1826226pdi.21
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 19:55:03 -0700 (PDT)
In-Reply-To: <536AE70F.7060307@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-08 at 10:08 +0800, Yang Yingliang wrote:
> On 2014/5/6 21:58, Eric Dumazet wrote:
> > On Tue, 2014-05-06 at 17:37 +0800, Yang Yingliang wrote:
> >> When packets are dropped, backlog and drops statistic of qdisc
> >> need be changed. Replace kfree_skb() with qdisc_drop() for
> >> increasing drops.
> >>
> >> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> >> ---
> > 
> > 
> >> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> >> index 0bf432c782c1..83abd4cd10cd 100644
> >> --- a/net/sched/sch_fq_codel.c
> >> +++ b/net/sched/sch_fq_codel.c
> >> @@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
> >>  	while (sch->q.qlen > sch->limit) {
> >>  		struct sk_buff *skb = fq_codel_dequeue(sch);
> >>  
> >> -		kfree_skb(skb);
> >> +		sch->qstats.backlog -= qdisc_pkt_len(skb);
> > 
> > Hmmm... please describe how you tested this change ?
> 
> Compiled only. The packet is dropped, so I think the backlog should be decreased.

Well, please test your patches then, and read again the code,
because you add a bug here.

Thanks.
