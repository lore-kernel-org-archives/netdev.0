From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6 NET] Fixes slab corruption in cbq_destroy
Date: Thu, 16 Sep 2004 15:47:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4149998C.6060501@trash.net>
References: <20040916132856.GA27293@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040916132856.GA27293@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>Fixes slab corruption in cbq_destroy. cbq_destroy_filters and
>qdisc_put_rtab(q->link.R_tab) are already called in cbq_destroy_class.
>The latter lead to a slab corruption due to repeated freeing of
>q->link.R_tab because q->link is part of q->classes. Problem introduced
>in 1.21.
>  
>
I don't see how there can be slab corruption. qdisc_put_rtab only
calls kfree if the table is found in qdisc_rtab_list, which only
happens once. But the patch is still fine as cleanup :)

Regards
Patrick

>Signed-off-by: Thomas Graf <tgraf@suug.ch>
>
>
>--- linux-2.6.9-rc2-bk2.orig/net/sched/sch_cbq.c	2004-09-16 14:52:23.000000000 +0200
>+++ linux-2.6.9-rc2-bk2/net/sched/sch_cbq.c	2004-09-16 14:53:53.000000000 +0200
>@@ -1770,10 +1770,6 @@
> #ifdef CONFIG_NET_CLS_POLICE
> 	q->rx_class = NULL;
> #endif
>-	for (h = 0; h < 16; h++) {
>-		for (cl = q->classes[h]; cl; cl = cl->next)
>-			cbq_destroy_filters(cl);
>-	}
> 
> 	for (h = 0; h < 16; h++) {
> 		struct cbq_class *next;
>@@ -1783,8 +1779,6 @@
> 			cbq_destroy_class(sch, cl);
> 		}
> 	}
>-
>-	qdisc_put_rtab(q->link.R_tab);
> }
> 
> static void cbq_put(struct Qdisc *sch, unsigned long arg)
>
>  
>
