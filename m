From: David Miller <davem@davemloft.net>
Subject: Re: deadlocks if use htb
Date: Sun, 18 Jan 2009 21:46:04 -0800 (PST)
Message-ID: <20090118.214604.221247372.davem@davemloft.net>
References: <1231937404.14825.4.camel@laptop>
	<Pine.LNX.4.64.0901141748300.17915@nacho.alt.net>
	<20090115065322.GA4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ccaputo@alt.net, a.p.zijlstra@chello.nl, denys@visp.net.lb,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	slavon@bigtelecom.ru, tglx@linutronix.de
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50674
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755566AbZASFqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:46:04 -0500
In-Reply-To: <20090115065322.GA4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 15 Jan 2009 06:53:22 +0000

> (resend testing patch #4 - for 2.6.27 or 2.6.28)

Jarek, if you deem that this is in fact what we should
submit for -stable please give me a submission with
a suitable commit message and signoffs, and I will queue
it up for -stable.

Thanks.

> diff -Nurp a2.6.27.7/net/sched/sch_htb.c b2.6.27.7/net/sched/sch_htb.c
> --- a2.6.27.7/net/sched/sch_htb.c	2008-12-11 08:16:16.000000000 +0000
> +++ b2.6.27.7/net/sched/sch_htb.c	2008-12-15 10:44:32.000000000 +0000
> @@ -924,6 +924,7 @@ static struct sk_buff *htb_dequeue(struc
>  		}
>  	}
>  	sch->qstats.overlimits++;
> +	qdisc_watchdog_cancel(&q->watchdog);
>  	qdisc_watchdog_schedule(&q->watchdog, next_event);
>  fin:
>  	return skb;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
