From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 10:12:20 +0300
Message-ID: <496EE1D4.6010709@bigtelecom.ru>
References: <20081010090426.GA6054@ff.dom.local> <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net> <20090114063909.GA4234@ff.dom.local> <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop> <Pine.LNX.4.64.0901141748300.17915@nacho.alt.net> <20090115065322.GA4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chris Caputo <ccaputo@alt.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:56096 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbZAOHMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 02:12:25 -0500
In-Reply-To: <20090115065322.GA4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Wed, Jan 14, 2009 at 06:02:04PM +0000, Chris Caputo wrote:
> ...
>   
>> That said, I would not recommend just the three for -stable unless they 
>> get a much wider amount of testing, on multiple platforms.  I don't see 
>> that as likely to happen, plus Peter says they are incomplete, so maybe it 
>> is just best to recommend that 2.6.28 users getting crashes while using 
>> HTB try these specific patches at first, and then the rest of the patches 
>> if they do not work.
>>     
>
> The main problem is my patches, at least the tested ones, harm htb's
> exactness, and I doubt I could convince anybody to merege them, at
> least before your case. It was only reported by two users here (plus
> one more on private), and looked like something very rare. After your
> report it looks much more necessary.
>
> If there is nothing better, I can recommend it, but IMHO the best
> candidate for this is the testing patch #4 from this thread, which
> alas wasn't even tested... So, Chris, if you could give it a try in
> the meantime (without any other patches)?
>
> Thanks,
> Jarek P.
>
> (resend testing patch #4 - for 2.6.27 or 2.6.28)
> ---
>
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
>
>   
Hello all.
I also can say this, maybe its help:
At old kernels my servers do 100% soft interupt if traffic more 600mbs.
Without your patches at new kernel i get crash only at heavy network
load PCs (more then 400mbs-500mbs). Servers that get 100-200 mbs not
crashed long time.
I remember that i not test patch #4, because you sat what its only
another way to temporary fix and mainline problem in hrtimer , but i try
turn on HiRes and Dynamic Tics in kernel - its not help for me.
Best Regals. Slavon
