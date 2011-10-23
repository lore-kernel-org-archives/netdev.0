From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 00/28 v6] m68k: Convert to genirq
Date: Sun, 23 Oct 2011 21:29:10 +1000
Message-ID: <4EA3FA86.7000905@snapgear.com>
References: <1315742394-16036-1-git-send-email-geert@linux-m68k.org>	<CAMuHMdWOhKcoDoyTnKJzruZ=gpV5uKNFpXnGCkrac7oEkCihJw@mail.gmail.com> <CAMuHMdX7C5NU5_MO5GdO=Pf2X59B3vFo4Y9B5wg-NQzwVbbLZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-m68k@lists.linux-m68k.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdX7C5NU5_MO5GdO=Pf2X59B3vFo4Y9B5wg-NQzwVbbLZA@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

On 10/23/2011 07:49 PM, Geert Uytterhoeven wrote:
> On Thu, Oct 20, 2011 at 14:18, Geert Uytterhoeven<geert@linux-m68k.or=
g>  wrote:
>> On Sun, Sep 11, 2011 at 13:59, Geert Uytterhoeven<geert@linux-m68k.o=
rg>  wrote:
>>> This patch series converts the m68k/mmu (nommu was converted before=
)
>>> architecture to the generic hardirq framework.
>>>
>>> =C3=A1- [01/28] genirq: Add missing "else" in irq_shutdown()
>>> =C3=A1- [02/28] ide-{cd,floppy,tape}: Do not include<linux/irq.>
>>> =C3=A1- [03/28] keyboard: Do not include<linux/irq.>
>>> =C3=A1- [04/28] m68k/irq: Rename irq_controller to irq_chip
>>> =C3=A1- [05/28] m68k/irq: Kill irq_node_t typedef, always use struc=
t irq_node
>>> =C3=A1- [06/28] m68k/irq: Rename irq_node to irq_data
>>> =C3=A1- [07/28] m68k/irq: Switch irq_chip methods to "struct irq_da=
ta *data"
>>> =C3=A1- [08/28] m68k/irq: Rename setup_irq() to m68k_setup_irq() an=
d make it static
>>> =C3=A1- [09/28] m68k/irq: Extract irq_set_chip()
>>> =C3=A1- [10/28] m68k/irq: Add m68k_setup_irq_controller()
>>> =C3=A1- [11/28] m68k/irq: Rename {,__}m68k_handle_int()
>>> =C3=A1- [12/28] m68k/irq: Remove obsolete IRQ_FLG_* definitions and=
 users
>>> =C3=A1- [13/28] m68k/irq: Add genirq support
>>> =C3=A1- [14/28] m68k/atari: Convert Atari to genirq
>>> =C3=A1- [15/28] m68k/atari: Remove code and comments about differen=
t irq types
>>> =C3=A1- [16/28] m68k/amiga: Refactor amiints.c
>>> =C3=A1- [17/28] m68k/amiga: Convert Amiga to genirq
>>> =C3=A1- [18/28] m68k/amiga: Optimize interrupts using chain handler=
s
>>> =C3=A1- [19/28] m68k/mac: Convert Mac to genirq
>>> =C3=A1- [20/28] m68k/mac: Optimize interrupts using chain handlers
>>> =C3=A1- [21/28] m68k/hp300: Convert HP9000/300 and HP9000/400 to ge=
nirq
>>> =C3=A1- [22/28] m68k/vme: Convert VME to genirq
>>> =C3=A1- [23/28] m68k/apollo: Convert Apollo to genirq
>>> =C3=A1- [24/28] m68k/sun3: Use the kstat_irqs_cpu() wrapper
>>> =C3=A1- [25/28] m68k/sun3: Convert Sun3/3x to genirq
>>> =C3=A1- [26/28] m68k/q40: Convert Q40/Q60 to genirq
>>> =C3=A1- [27/28] m68k/irq: Remove obsolete m68k irq framework
>>> =C3=A1- [28/28] m68k/irq: Remove obsolete support for user vector i=
nterrupt fixups
>>>
>>> Overview:
>>> =C3=A1- [01] is a fix for the core genirq code,
>>
>> This went into v3.1-rc6.
>>
>>> =C3=A1- [02-03] are fixes to avoid compile problems later in the co=
nversion
>>> =C3=A1 =C3=A1process,
>>
>> The keyboard path went into the tty -next tree.
>> The IDE one is still pending (I've just resent it).
>
> The IDE one got acked in the mean time.
>
>>> I will update my m68k-genirq branch as soon as master.kernel.org is=
 available
>>> again.
>>
>> Updated, on top of m68k master (which is at v3.1-rc10 now).
>> http://git.kernel.org/?p=3Dlinux/kernel/git/geert/linux-m68k.git;a=3D=
shortlog;h=3Drefs/heads/m68k-genirq
>>
>> If noone objects, I'd like to add this to the m68k master and for-3.=
2 branches.
>
> I added it to m68k master.
>
> As there were several merge conflicts with current -next
> (arch/m68k/kernel/Makefile_mm
> due to the mmu/nommu merge, and drivers/net/macsonic.c in [12/28] due
> to the network
> driver reshuffling dance), I did not add it to for-3.2 and for-next,
> but to for-3.3.
>
> Depending on Stephen's return during or after the merge window, and
> the merge timing
> of the m68knommu and netdev trees, I may stil try to sneak it in 3.2,=
 though.

I can ask Linus to pull the m68knommu tree early in the merge window,
if that will help.

Regards
Greg


-----------------------------------------------------------------------=
-
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.co=
m
SnapGear Group, McAfee                      PHONE:       +61 7 3435 288=
8
8 Gardner Close,                            FAX:         +61 7 3891 363=
0
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.co=
m
