From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70
	check_irq_resend()
Date: Fri, 10 Aug 2007 10:05:40 +0200
Message-ID: <1186733140.12828.45.camel@chaos>
References: <18107.11431.838905.331157@stoffel.org>
	 <20070809155445.GA5161@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, vignaud@xandmail.fr,
	marcin.slusarz@gmail.com, mingo@elte.hu,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070809155445.GA5161@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-09 at 17:54 +0200, Jarek Poplawski wrote:
> I'm not sure I don't miss anything (a little in hurry now), but this
> warning's aim was purely diagnostical and nothing wrong is meant!
> Unless there is something wrong... Then please try to be more explicit.
> 
> If you prefer to not see this, there is my patch proposal somewhere
> in this older thread:
> Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
> Date: Wed, 8 Aug 2007 13:00:37 +0200
> 
> On the other hand, if it works OK, it would be better to let it be
> tested more like this...

Hmm. This solution is still just pampering over the real problem. The
delayed disable just re-sends level interrupts unnecessarily. I have a
fix (needs some testing) for this, which I send out tomorrow, when I'm
really back from vacation.

But suppressing the resend is not fixing the driver problem. The problem
can show up with spurious interrupts and with interrupts on a shared PCI
interrupt line at any time. It just might take weeks instead of minutes.

Alan,

is there anything which can be done on the driver level ?

	tglx


