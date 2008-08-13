From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Wed, 13 Aug 2008 08:49:31 +0000
Message-ID: <20080813084931.GC5367@ff.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <200808131028.11153.denys@visp.net.lb> <20080813074326.GB5367@ff.dom.local> <200808131102.34988.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:43951 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756693AbYHMItk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 04:49:40 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2642027fkq.5
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 01:49:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808131102.34988.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 11:02:34AM +0300, Denys Fedoryshchenko wrote:
> As soon as kernel reboot themself, it won't hurt me much.
> With NMI watchdog i notice there was panic missing, so nmi_watchdog was 
> showing message and was not rebooting. It is fixed in next kernel and i patch 
> in my kernel - so i will not crash+freeze anymore i guess and will not need 
> to run to power switch at night.
> 
> It can be related to another problem (some corruption) which is not fixed yet, 
> so prefferably to show timer guys exact location of problem.
> 
> Maybe you can make some patch like:
> 
> +	if (q->next_watchdog < q->now || next_event <=
> +	     q->next_watchdog - PSCHED_TICKS_PER_SEC / (10 * HZ)) {
> +		qdisc_watchdog_schedule(&q->watchdog, next_event);
> +		q->next_watchdog = next_event;
> +	} else {
> something like BUG()
>          }
> ?

I don't think it's right: there could be probably some small time
differences between cpus on SMP or even some inaccuracy related to
hardware, but I don't think it's the right place or method to verify
this. And eg. re-scheduling with the same time shouldn't be wrong too.

Anyway, narrowing the problem with such tests should give us better
understanding what could be a real problem here. BTW, could you
"remind" us the .config on this box (especially various *HZ*, *TIME*
and *TIMERS* settings).

> Probably also i will try to migrate to "rc" versions of kernel to see if 
> problem still exist there, a lot of changes done there... is HTB corruption 
> problem tracked finally and completely? I seen some discussions about it 
> recently...

I doubt current rc versions are stable enough for any production. HTB
waits for one fix, but it's nothing critical if it didn't bothered you
until now. There could be still some problems around schedulers
generally, after last big changes.

Jarek P.
