From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 00/28 v6] m68k: Convert to genirq
Date: Sun, 23 Oct 2011 11:49:55 +0200
Message-ID: <CAMuHMdX7C5NU5_MO5GdO=Pf2X59B3vFo4Y9B5wg-NQzwVbbLZA@mail.gmail.com>
References: <1315742394-16036-1-git-send-email-geert@linux-m68k.org>
	<CAMuHMdWOhKcoDoyTnKJzruZ=gpV5uKNFpXnGCkrac7oEkCihJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux-m68k@lists.linux-m68k.org, Greg Ungerer <gerg@snapgear.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWOhKcoDoyTnKJzruZ=gpV5uKNFpXnGCkrac7oEkCihJw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2011 at 14:18, Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
> On Sun, Sep 11, 2011 at 13:59, Geert Uytterhoeven <geert@linux-m68k.o=
rg> wrote:
>> This patch series converts the m68k/mmu (nommu was converted before)
>> architecture to the generic hardirq framework.
>>
>> =C2=A0- [01/28] genirq: Add missing "else" in irq_shutdown()
>> =C2=A0- [02/28] ide-{cd,floppy,tape}: Do not include <linux/irq.>
>> =C2=A0- [03/28] keyboard: Do not include <linux/irq.>
>> =C2=A0- [04/28] m68k/irq: Rename irq_controller to irq_chip
>> =C2=A0- [05/28] m68k/irq: Kill irq_node_t typedef, always use struct=
 irq_node
>> =C2=A0- [06/28] m68k/irq: Rename irq_node to irq_data
>> =C2=A0- [07/28] m68k/irq: Switch irq_chip methods to "struct irq_dat=
a *data"
>> =C2=A0- [08/28] m68k/irq: Rename setup_irq() to m68k_setup_irq() and=
 make it static
>> =C2=A0- [09/28] m68k/irq: Extract irq_set_chip()
>> =C2=A0- [10/28] m68k/irq: Add m68k_setup_irq_controller()
>> =C2=A0- [11/28] m68k/irq: Rename {,__}m68k_handle_int()
>> =C2=A0- [12/28] m68k/irq: Remove obsolete IRQ_FLG_* definitions and =
users
>> =C2=A0- [13/28] m68k/irq: Add genirq support
>> =C2=A0- [14/28] m68k/atari: Convert Atari to genirq
>> =C2=A0- [15/28] m68k/atari: Remove code and comments about different=
 irq types
>> =C2=A0- [16/28] m68k/amiga: Refactor amiints.c
>> =C2=A0- [17/28] m68k/amiga: Convert Amiga to genirq
>> =C2=A0- [18/28] m68k/amiga: Optimize interrupts using chain handlers
>> =C2=A0- [19/28] m68k/mac: Convert Mac to genirq
>> =C2=A0- [20/28] m68k/mac: Optimize interrupts using chain handlers
>> =C2=A0- [21/28] m68k/hp300: Convert HP9000/300 and HP9000/400 to gen=
irq
>> =C2=A0- [22/28] m68k/vme: Convert VME to genirq
>> =C2=A0- [23/28] m68k/apollo: Convert Apollo to genirq
>> =C2=A0- [24/28] m68k/sun3: Use the kstat_irqs_cpu() wrapper
>> =C2=A0- [25/28] m68k/sun3: Convert Sun3/3x to genirq
>> =C2=A0- [26/28] m68k/q40: Convert Q40/Q60 to genirq
>> =C2=A0- [27/28] m68k/irq: Remove obsolete m68k irq framework
>> =C2=A0- [28/28] m68k/irq: Remove obsolete support for user vector in=
terrupt fixups
>>
>> Overview:
>> =C2=A0- [01] is a fix for the core genirq code,
>
> This went into v3.1-rc6.
>
>> =C2=A0- [02-03] are fixes to avoid compile problems later in the con=
version
>> =C2=A0 =C2=A0process,
>
> The keyboard path went into the tty -next tree.
> The IDE one is still pending (I've just resent it).

The IDE one got acked in the mean time.

>> I will update my m68k-genirq branch as soon as master.kernel.org is =
available
>> again.
>
> Updated, on top of m68k master (which is at v3.1-rc10 now).
> http://git.kernel.org/?p=3Dlinux/kernel/git/geert/linux-m68k.git;a=3D=
shortlog;h=3Drefs/heads/m68k-genirq
>
> If noone objects, I'd like to add this to the m68k master and for-3.2=
 branches.

I added it to m68k master.

As there were several merge conflicts with current -next
(arch/m68k/kernel/Makefile_mm
due to the mmu/nommu merge, and drivers/net/macsonic.c in [12/28] due
to the network
driver reshuffling dance), I did not add it to for-3.2 and for-next,
but to for-3.3.

Depending on Stephen's return during or after the merge window, and
the merge timing
of the m68knommu and netdev trees, I may stil try to sneak it in 3.2, t=
hough.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
