From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6] cache align qdisc data
Date: Tue, 03 Aug 2004 21:17:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FE4DD.5000306@trash.net>
References: <410FAE42.2050909@trash.net> <20040803083820.711c917c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803083820.711c917c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>This patch has qdisc code use the same interface as the netdevice code
>to cache align the object private data.
>  
>
These two hunks look bogus.

>diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
>--- a/net/sched/sch_hfsc.c	2004-07-27 11:03:02 -07:00
>+++ b/net/sched/sch_hfsc.c	2004-07-27 11:03:02 -07:00
>@@ -1554,7 +1554,6 @@
> 	qopt = RTA_DATA(opt);
> 
> 	memset(q, 0, sizeof(struct hfsc_sched));
>-	sch->stats_lock = &sch->dev->queue_lock;
> 
> 	q->defcls = qopt->defcls;
> 	for (i = 0; i < HFSC_HSIZE; i++)
>
>@@ -1674,7 +1673,7 @@
> 	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
> 
> 	sch->stats.qlen = sch->q.qlen;
>-	if (qdisc_copy_stats(skb, &sch->stats, sch->stats_lock) < 0)
>+	if (qdisc_copy_stats(skb, &sch->stats, &sch->dev->queue_lock) < 0)
> 		goto rtattr_failure;
> 
> 	return skb->len;
>  
>
