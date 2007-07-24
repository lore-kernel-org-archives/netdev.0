From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 24 Jul 2007 09:18:58 +0200
Message-ID: <20070724071858.GA2049@ff.dom.local>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com> <20070629150759.GC2771@ff.dom.local> <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 23, 2007 at 07:44:58AM +0200, Marcin =A6lusarz wrote:
> Ok, I've bisected this problem and found that this patch broke my NIC=
:
>=20
> 76d2160147f43f982dfe881404cfde9fd0a9da21 is first bad commit
> commit 76d2160147f43f982dfe881404cfde9fd0a9da21
> Author: Ingo Molnar <mingo@elte.hu>
> Date:   Fri Feb 16 01:28:24 2007 -0800
>=20
>    [PATCH] genirq: do not mask interrupts by default
>=20
>    Never mask interrupts immediately upon request.  Disabling interru=
pts in
>    high-performance codepaths is rare, and on the other hand this cha=
nge=20
>    could
>    recover lost edges (or even other types of lost interrupts) by
> conservatively
>    only masking interrupts after they happen.  (NOTE: with this chang=
e the
>    highlevel irq-disable code still soft-disables this IRQ line - and
> if such an
>    interrupt happens then the IRQ flow handler keeps the IRQ masked.)
>=20
>    Mark i8529A controllers as 'never loses an edge'.
>=20
>    Signed-off-by: Ingo Molnar <mingo@elte.hu>
>    Cc: Thomas Gleixner <tglx@linutronix.de>
>    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

So, it seems nobody (except the users) cares...

BTW, maybe there should be created something like "Network Cards
Producers Made Rich on Unnecessary Changed Cards Linux Foundation"?:

On Fri, Jun 29, 2007 at 10:50:20AM +0200, Jean-Baptiste Vignaud wrote:
=2E..
> 2) changed the 3com cards
> i replaced by two cards,
> 01:06.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II]=
 (rev 42)
> 01:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8029=
(AS)
>=20
> reinstalled and stressed the network (small download from a laptop) a=
nd :
>=20
> Jun 29 09:34:10 loki kernel: NETDEV WATCHDOG: eth0: transmit timed ou=
t
> Jun 29 09:34:51 loki last message repeated 14 times
> Jun 29 09:35:18 loki last message repeated 8 times

=2E..Of course, no response of any "serious" developer for this as well=
=2E

BTW #2: I wonder how true is this (after above-mentioned patch):

=46rom include/linux/irq.h:
> /**
>  * struct irq_chip - hardware interrupt chip descriptor
=2E..
>  * @disable:		disable the interrupt (defaults to chip->mask if NULL)

Regards,
Jarek P.
