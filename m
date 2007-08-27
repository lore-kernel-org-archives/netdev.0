From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 2.6.23-rc3-mm1] request_irq fix DEBUG_SHIRQ handling Re: 2.6.23-rc2-mm1: rtl8139 inconsistent lock state
Date: Mon, 27 Aug 2007 07:54:26 +0200
Message-ID: <20070827055426.GA1703@ff.dom.local>
References: <20070822133511.GH1684@ff.dom.local> <200708251143.09425.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:48764 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751357AbXH0FxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 01:53:11 -0400
Content-Disposition: inline
In-Reply-To: <200708251143.09425.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 25, 2007 at 11:43:08AM +0200, Mariusz Kozlowski wrote:
> > > =================================
> > > [ INFO: inconsistent lock state ]
> > > 2.6.23-rc2-mm1 #7
> > > ---------------------------------
> > > inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
> > > ifconfig/5492 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > >  (&tp->lock){+...}, at: [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
...
> I tested your patch and it still happens. Dmesg info from patched kernel attached.
> I coulnd't reproduce that on 2.6.23-rc3-mm1 - but on 2.6.23-rc2-mm2 it is easily
> reproducible.
> 
> If you need more info, test some patches, etc. - just mail me.
> 
...
> =========================================================
> [ INFO: possible irq lock inversion dependency detected ]
> 2.6.23-rc2-mm2 #2
> ---------------------------------------------------------
> runscript.sh/5065 just changed the state of lock:
>  (_xmit_ETHER){-+..}, at: [<c03cb659>] dev_watchdog+0x17/0xcc
> but this lock took another, soft-irq-unsafe lock in the past:
>  (&tp->lock){--..}
> 
> and interrupts could create inverse lock ordering between them.

It's OK! These're 2 different warnings. As a matter of fact, my patch
wasn't supposed to fix any of them, but something similar to the first
one, which was possible, but for some reason wasn't reported by
lockdep.

The first warning was fixed by Andrew Morton's patch to free_irq(),
so it shouldn't happen in -rc3-mm. The second warning could have been
fixed too, I don't know, but since it's quite long, I would prefer to
think about it only if it still happens in current -mm's.

Thanks,
Jarek P.
