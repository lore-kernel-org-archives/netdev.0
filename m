From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 7 Aug 2007 14:55:18 +0200
Message-ID: <20070807125518.GA4669@ff.dom.local>
References: <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com> <20070807082321.GB2120@ff.dom.local> <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com> <20070807095246.GB3223@ff.dom.local> <20070807121339.GA3946@ff.dom.local>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:59598 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754024AbXHGMyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 08:54:49 -0400
Content-Disposition: inline
In-Reply-To: <20070807121339.GA3946@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 02:13:39PM +0200, Jarek Poplawski wrote:
> On Tue, Aug 07, 2007 at 11:52:46AM +0200, Jarek Poplawski wrote:
> > On Tue, Aug 07, 2007 at 11:37:01AM +0200, Marcin =A6lusarz wrote:
=2E..
> > > No, i don't need a break. I'll have more time in next weeks.
> >=20
> > Great! So, I'll try to send a patch with _SW_RESEND in a few hours,
> > if Ingo doesn't prepare something for you.
>=20
> So, the let's try this idea yet: modified Ingo's "x86: activate
> HARDIRQS_SW_RESEND" patch.
> (Don't forget about make oldconfig before make.)
> For testing only.
>=20
> Cheers,
> Jarek P.
>=20
> PS: alas there was not even time for "compile checking"...

And here is one more patch to test the same idea (chip->retrigger()).
Let's try i386 way! (I hope I will not be arrested for this...)
(Should be tested without any previous patches.)

Jarek P.

PS: as above

---

diff -Nurp 2.6.22.1-/arch/x86_64/kernel/io_apic.c 2.6.22.1/arch/x86_64/=
kernel/io_apic.c
--- 2.6.22.1-/arch/x86_64/kernel/io_apic.c	2007-07-09 01:32:17.00000000=
0 +0200
+++ 2.6.22.1/arch/x86_64/kernel/io_apic.c	2007-08-07 14:37:45.000000000=
 +0200
@@ -1311,15 +1311,8 @@ static unsigned int startup_ioapic_irq(u
 static int ioapic_retrigger_irq(unsigned int irq)
 {
 	struct irq_cfg *cfg =3D &irq_cfg[irq];
-	cpumask_t mask;
-	unsigned long flags;
-
-	spin_lock_irqsave(&vector_lock, flags);
-	cpus_clear(mask);
-	cpu_set(first_cpu(cfg->domain), mask);
=20
-	send_IPI_mask(mask, cfg->vector);
-	spin_unlock_irqrestore(&vector_lock, flags);
+	send_IPI_self(cfg->vector);
=20
 	return 1;
 }
