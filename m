From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 12:40:59 +0300
Message-ID: <496F04AB.2080705@bigtelecom.ru>
References: <20081010090426.GA6054@ff.dom.local> <496EE1D4.6010709@bigtelecom.ru> <20090115080921.GC4190@ff.dom.local> <200901151101.15397.denys@visp.net.lb> <20090115090650.GF4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Chris Caputo <ccaputo@alt.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:43972 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755169AbZAOJlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 04:41:04 -0500
In-Reply-To: <20090115090650.GF4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, Jan 15, 2009 at 11:01:14AM +0200, Denys Fedoryschenko wrote:
> ...
>  =20
>> Jarek, can you give me exact name of patch or link to it?
>> I will test it on production.
>> And i am interested in searching, what is a problem.
>>    =20
>
> If there is nothing better I could recommend the patch below for
> -stable (2.6.28), when it's tested.
>
> Thanks,
> Jarek P.
> ---
>
> diff -Nurp a2.6.27.7/net/sched/sch_htb.c b2.6.27.7/net/sched/sch_htb.=
c
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
>
>  =20

Jarek, i easy can test patch 4 without 2+3 if it needed at heavy
production server. I use dynamic routing and if server crashed - traffi=
c
go to another pc after few seconds. I not test it because you say that
its not needed if for me help 3+2. I apply it today and test at few ser=
vers.
