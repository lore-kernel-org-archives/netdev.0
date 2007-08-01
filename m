From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 1 Aug 2007 09:24:01 +0200
Message-ID: <4bacf17f0708010024r3abc196dv4d6924e314536b17@mail.gmail.com>
References: <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
	 <1185322771.4175.102.camel@chaos>
	 <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com>
	 <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos>
	 <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local>
	 <20070726091254.GA8063@elte.hu>
	 <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
	 <20070730084925.GA12695@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070730084925.GA12695@elte.hu>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/7/30, Ingo Molnar <mingo@elte.hu>:
> (..)
> does the patch below fix those timeouts? It tests the theory whether any
> POST latency could expose this problem.
>
>         Ingo
>
> Index: linux/drivers/net/lib8390.c
> ===================================================================
> --- linux.orig/drivers/net/lib8390.c
> +++ linux/drivers/net/lib8390.c
> @@ -375,6 +375,8 @@ static int ei_start_xmit(struct sk_buff
>         /* Turn 8390 interrupts back on. */
>         ei_local->irqlock = 0;
>         ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
> +       /* force POST: */
> +       ei_inb_p(e8390_base + EN0_IMR);
>
>         spin_unlock(&ei_local->page_lock);
>         enable_irq_lockdep_irqrestore(dev->irq, &flags);
>

Bad news. It doesn't fix the problem.

Marcin
