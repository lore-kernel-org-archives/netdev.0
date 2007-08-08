From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 8 Aug 2007 13:11:20 +0200
Message-ID: <4bacf17f0708080411r3a7c3b78je3e1189d04a65f38@mail.gmail.com>
References: <20070726091254.GA8063@elte.hu>
	 <20070731132037.GC1046@ff.dom.local>
	 <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com>
	 <20070806070300.GA4509@elte.hu>
	 <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com>
	 <20070807082321.GB2120@ff.dom.local>
	 <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com>
	 <20070807095246.GB3223@ff.dom.local>
	 <20070807121339.GA3946@ff.dom.local>
	 <20070807125518.GA4669@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:53051 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbXHHLLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 07:11:21 -0400
Received: by wa-out-1112.google.com with SMTP id v27so161100wah
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2007 04:11:21 -0700 (PDT)
In-Reply-To: <20070807125518.GA4669@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/8/7, Jarek Poplawski <jarkao2@o2.pl>:
> And here is one more patch to test the same idea (chip->retrigger()).
> Let's try i386 way! (I hope I will not be arrested for this...)
> (Should be tested without any previous patches.)
>
> Jarek P.
>
> PS: as above
>
> ---
>
> diff -Nurp 2.6.22.1-/arch/x86_64/kernel/io_apic.c 2.6.22.1/arch/x86_64/kernel/io_apic.c
> --- 2.6.22.1-/arch/x86_64/kernel/io_apic.c      2007-07-09 01:32:17.000000000 +0200
> +++ 2.6.22.1/arch/x86_64/kernel/io_apic.c       2007-08-07 14:37:45.000000000 +0200
> @@ -1311,15 +1311,8 @@ static unsigned int startup_ioapic_irq(u
>  static int ioapic_retrigger_irq(unsigned int irq)
>  {
>         struct irq_cfg *cfg = &irq_cfg[irq];
> -       cpumask_t mask;
> -       unsigned long flags;
> -
> -       spin_lock_irqsave(&vector_lock, flags);
> -       cpus_clear(mask);
> -       cpu_set(first_cpu(cfg->domain), mask);
>
> -       send_IPI_mask(mask, cfg->vector);
> -       spin_unlock_irqrestore(&vector_lock, flags);
> +       send_IPI_self(cfg->vector);
>
>         return 1;
>  }
>
Network card timed out with this patch.

Marcin
