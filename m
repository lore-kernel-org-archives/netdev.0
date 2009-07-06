From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Mon, 6 Jul 2009 10:14:32 +0200
Message-ID: <20090706081432.GA3065@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <20090704151855.GA21896@ami.dom.local> <a5d9929e0907052153x2db851bcj26f1433c716c8a90@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andres Freund <andres@anarazel.de>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:40504 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756996AbZGFIPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 04:15:03 -0400
Content-Disposition: inline
In-Reply-To: <a5d9929e0907052153x2db851bcj26f1433c716c8a90@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 06, 2009 at 05:53:51AM +0100, Joao Correia wrote:
> Hello
Hi,

> System freezes immediatly after grub, no init processing at all, after
> applying those patches on top of vanilla 2.6.30 on my box.
> 
> Also, 2nd patch, this piece:
> 
> +#ifdef CONFIG_SCHED_DEBUG
> +static inline unsigned int get_sysctl_timer_migration(void)
> +{
> +       return sysctl_timer_migration;
> +}
> +#else
> +static inline unsigned int get_sysctl_timer_migration(void)
> +{
> +       return 1;
> +}
> +#endif
> 
> doesnt work on top of 2.6.30. It complains, while compiling, that
> sysctl_timer_migration is not defined. So i just replaced that call
> with return 1, like on the not debug case. Hope this doesnt defeat
> your test case, but it wouldnt compile otherwise. Probably that was
> just introduced after 2.6.30?

Yes, it would be too easy if it had worked just like this... (I only
test-compiled it, without such warnings, but without CONFIG_SCHED_DEBUG.)
I'll look at this again.

> 
> (Have also tried latest .31-rc2, original bug still exists.)

Btw., could you send your .config? Do you have lockdep enabled (if so
did you try without it)? Is it 'a real' box or something virtual?

Thanks,
Jarek P.
