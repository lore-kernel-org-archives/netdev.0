From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon, 30 Jul 2007 14:05:17 +0100
Message-ID: <20070730140517.68babf76@the-village.bc.nu>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
	<20070629150759.GC2771@ff.dom.local>
	<4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
	<20070724080534.GC18740@elte.hu>
	<20070724094202.GA11610@elte.hu>
	<alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
	<20070724200431.GA22190@elte.hu>
	<1185322771.4175.102.camel@chaos>
	<20070725135718.GB1843@ff.dom.local>
	<20070725154656.54fd6f13@the-village.bc.nu>
	<20070730084651.GA14146@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Marcin ??lusarz <marcin.slusarz@gmail.com>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:38742 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760057AbXG3M7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 08:59:00 -0400
In-Reply-To: <20070730084651.GA14146@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So the whole locking is to be able to keep irqs enabled for a long time, 
> without risking entry of the same IRQ handler on this same CPU, correct?

As implemented - on any CPU.

We also need to know that the IRQ handler is not doing useful work on
another processor which is why we take the lock after disabling the
interrupt line everywhere. Without that we might be completing an IRQ on
another CPU and that would race the transmit and make a nasty mess.

> So it seems to me that maybe the driver could be surprised via these 
> spurious interrupts that happen right after the irq_enable(). Does the 
> patch below make any sense in your opinion?

For MMIO it does look like that may be needed. Looks sensible.

