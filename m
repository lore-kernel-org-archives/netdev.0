From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after random time
Date: Fri, 10 Aug 2007 09:10:38 +0200
Message-ID: <20070810071038.GA1764@ff.dom.local>
References: <20070806070300.GA4509@elte.hu> <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com> <20070807082321.GB2120@ff.dom.local> <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com> <20070807095246.GB3223@ff.dom.local> <20070807121339.GA3946@ff.dom.local> <4bacf17f0708080409t116b5c84ye60dff7da51d0fdf@mail.gmail.com> <20070808114243.GC2426@ff.dom.local> <20070809091919.GB2423@ff.dom.local> <4bacf17f0708092333n17e0ba19jf2c769531610868d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0708092333n17e0ba19jf2c769531610868d@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 08:33:27AM +0200, Marcin =A6lusarz wrote:
> 2007/8/9, Jarek Poplawski <jarkao2@o2.pl>:
=2E..
> > diff -Nurp 2.6.23-rc1-/kernel/irq/chip.c 2.6.23-rc1/kernel/irq/chip=
=2Ec
> > --- 2.6.23-rc1-/kernel/irq/chip.c       2007-07-09 01:32:17.0000000=
00 +0200
> > +++ 2.6.23-rc1/kernel/irq/chip.c        2007-08-08 20:49:07.0000000=
00 +0200
> > @@ -389,12 +389,19 @@ handle_fasteoi_irq(unsigned int irq, str
> >         unsigned int cpu =3D smp_processor_id();
> >         struct irqaction *action;
> >         irqreturn_t action_ret;
> > +       int edge =3D 0;
> >
=2E..
> NETDEV WATCHDOG: eth0: transmit timed out
> eth0: Tx timed out, lost interrupt? TSR=3D0x3, ISR=3D0x3, t=3D351.
> eth0: Resetting the 8390 t=3D4295229000...<6>NETDEV WATCHDOG: eth0:
> transmit timed out
> eth0: Tx timed out, lost interrupt? TSR=3D0x3, ISR=3D0x3, t=3D718.
> eth0: Resetting the 8390 t=3D4295230000...<6>NETDEV WATCHDOG: eth0:
> transmit timed out
> eth0: Tx timed out, lost interrupt? TSR=3D0x3, ISR=3D0x3, t=3D874.
> etc...

So, we still have to wait for the exact explanation...

Thanks very much Marcin!

I think, there is this one possible for your testing yet?:
Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
Date: Wed, 8 Aug 2007 13:00:37 +0200

If it's not a great problem it would be interesting to try this with
different CONFIG_HZ too e.g. you could start with 100 (I guess, you
tested very similar thing in 2.6.23-rc2 with 1000(?) already).

Jean-Baptiste: you can skip/break testing of this 'experimental'
patch, too.

Regards,
Jarek P.
