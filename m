From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 16:30:47 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0412051622380.29474@tux.rsn.bth.se>
References: <1101821501.1043.43.camel@jzny.localdomain>
 <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain>
 <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
 <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org>
 <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org>
 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <20041205151545.GC647@xi.wantstofly.org>
 <Pine.LNX.4.58.0412051616090.29474@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <Pine.LNX.4.58.0412051616090.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Martin Josefsson wrote:

> > > The hardware is a dual Athlon MP 2000+ in an Asus A7M266-D motherboard and
> > > the nic is located in a 64/66 slot.
> >
> > Hmmm.  Funny you get this number even on 64/66.  How many PCI bridges
> > between the CPUs and the NIC?  Any idea how many cycles an MMIO read on
> > your hardware is?
>
> I verified that I get the same results on a small whimpy 82540EM that runs
> at 32/66 as well. Just about to see what I get at 32/33 with that card.

Just tested the 82540EM at 32/33 and it's a big diffrence.

60      350229
64      247037
68      219643
72      218205
76      216786
80      215386
84      214003
88      212638
92      211291
96      210004
100     208647
104     182461
108     181468
112     180453
116     179482
120     185472
124     188336
128     153743


Sorry, forgot to answer your other questions, I'm a bit excited at the
moment :)

The 64/66 bus on this motherboard is directly connected to the
northbridge. Here's the lspci output with the 82546GB nic attached
to the 64/66 bus and 82540EM nic connected to the 32/33 bus that hangs
off the southbridge:

00:00.0 Host bridge: Advanced Micro Devices [AMD] AMD-760 MP [IGD4-2P] System Controller (rev 11)
00:01.0 PCI bridge: Advanced Micro Devices [AMD] AMD-760 MP [IGD4-2P] AGP Bridge
00:07.0 ISA bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] ISA (rev 05)
00:07.1 IDE interface: Advanced Micro Devices [AMD] AMD-768 [Opus] IDE (rev 04)
00:07.3 Bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] ACPI (rev 03)
00:08.0 Ethernet controller: Intel Corp. 82546GB Gigabit Ethernet Controller (rev 03)
00:08.1 Ethernet controller: Intel Corp. 82546GB Gigabit Ethernet Controller (rev 03)
00:10.0 PCI bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] PCI (rev 05)
01:05.0 VGA compatible controller: Silicon Integrated Systems [SiS] 86C326 5598/6326 (rev 0b)
02:05.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 0c)
02:06.0 SCSI storage controller: Adaptec AIC-7892A U160/m (rev 02)
02:08.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet Controller (rev 02)

And lspci -t

-[00]-+-00.0
      +-01.0-[01]----05.0
      +-07.0
      +-07.1
      +-07.3
      +-08.0
      +-08.1
      \-10.0-[02]--+-05.0
                   +-06.0
                   \-08.0

I have no idea how expensive an MMIO read is on this machine, do you have
an relatively easy way to find out?

/Martin
