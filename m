From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: [patch] genirq: temporary fix for level-triggered IRQ resend
Date: Thu, 02 Aug 2007 19:03:03 +0200
Message-ID: <46B20E47.6020403@googlemail.com>
References: <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org> <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos> <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com> <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731155843.GA7033@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jarek Poplawski <jarkao2@o2.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, marcin.slusarz@gmail.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:6134 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbXHBRDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 13:03:16 -0400
Received: by nf-out-0910.google.com with SMTP id g13so153551nfb
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2007 10:03:14 -0700 (PDT)
In-Reply-To: <20070731155843.GA7033@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> Linus,
> 
> with -rc2 approaching i think we should apply the minimal fix below to 
> get Marcin's ne2k-pci networking back in working order. The 
> WARN_ON_ONCE() will not prevent the system from working and it will be a 
> reminder.
> 
> a better workaround would be to inhibit the resent vector via the 
> IO-APIC irqchip - but i'd still like to have the patch below because the 
> ne2k driver _should_ be able to survive the spurious irq that happens. 
> (even on Marcin's system that ne2k-pci irq line is shared with another 
> networking card, so an irq could happen at any moment - it's just that 
> with the delayed-disable logic it happens _all the time_.)
> 

I get a warning on each boot now with this patch .. 

[   63.686613] WARNING: at kernel/irq/resend.c:70 check_irq_resend()
[   63.686636]  [<c013c55c>] check_irq_resend+0x8c/0xa0
[   63.686653]  [<c013c15f>] enable_irq+0xad/0xb3
[   63.686662]  [<e886481e>] vortex_timer+0x20c/0x3d5 [3c59x]
[   63.686675]  [<c01164b9>] scheduler_tick+0x154/0x273
[   63.686685]  [<c012fed1>] getnstimeofday+0x34/0xe3
[   63.686697]  [<c0121f4a>] run_timer_softirq+0x137/0x197
[   63.686709]  [<e8864612>] vortex_timer+0x0/0x3d5 [3c59x]
[   63.686720]  [<c011ed09>] __do_softirq+0x75/0xe1
[   63.686729]  [<c011edac>] do_softirq+0x37/0x3d
[   63.686735]  [<c011ef85>] irq_exit+0x7c/0x7e
[   63.686740]  [<c010e013>] smp_apic_timer_interrupt+0x59/0x84
[   63.686751]  [<c0103428>] apic_timer_interrupt+0x28/0x30
[   63.686759]  [<c0101355>] default_idle+0x0/0x3f
[   63.686767]  [<c0101385>] default_idle+0x30/0x3f
[   63.686773]  [<c0100c19>] cpu_idle+0x5e/0x8e
[   63.686779]  [<c03fdc5f>] start_kernel+0x2d7/0x368


That means ?:)


> 	Ingo
> 


Gabriel
