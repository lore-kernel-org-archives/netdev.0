From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 18:38:05 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0412051836020.29474@tux.rsn.bth.se>
References: <20041201001107.GE4203@xi.wantstofly.org>
 <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
 <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org>
 <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org>
 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <20041205151545.GC647@xi.wantstofly.org>
 <Pine.LNX.4.58.0412051616090.29474@tux.rsn.bth.se>
 <Pine.LNX.4.58.0412051622380.29474@tux.rsn.bth.se> <20041205170006.GI647@xi.wantstofly.org>
 <Pine.LNX.4.58.0412051804370.29474@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <Pine.LNX.4.58.0412051804370.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Martin Josefsson wrote:

> > -#define E1000_READ_REG(a, reg) ( \
> > -    readl((a)->hw_addr + \
> > -        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)))
> > +#define E1000_READ_REG(a, reg) ({ \
> > +    unsigned long s, e, d, v; \
> > +\
> > +    (a)->mmio_reads++; \
> > +    rdtsc(s, d); \
> > +    v = readl((a)->hw_addr + \
> > +        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)); \
> > +    rdtsc(e, d); \
> > +    e -= s; \
> > +    printk(KERN_INFO "e1000: MMIO read took %ld clocks\n", e); \
> > +    printk(KERN_INFO "e1000: in process %d(%s)\n", current->pid, current->comm); \
> > +    dump_stack(); \
> > +    v; \
> > +})
> >
> > You might want to disable the stack dump of course.
>
> Will test this in a while.

It gives pretty varied results.
This is during a pktgen run.

The machine is an Athlon MP 2000+ which operated at 1667 MHz

e1000: MMIO read took 481 clocks
e1000: MMIO read took 369 clocks
e1000: MMIO read took 481 clocks
e1000: MMIO read took 11 clocks
e1000: MMIO read took 477 clocks
e1000: MMIO read took 316 clocks
e1000: MMIO read took 481 clocks
e1000: MMIO read took 316 clocks
e1000: MMIO read took 480 clocks
e1000: MMIO read took 332 clocks
e1000: MMIO read took 480 clocks
e1000: MMIO read took 372 clocks
e1000: MMIO read took 480 clocks
e1000: MMIO read took 11 clocks
e1000: MMIO read took 481 clocks
e1000: MMIO read took 388 clocks
e1000: MMIO read took 480 clocks
e1000: MMIO read took 11 clocks
e1000: MMIO read took 485 clocks
e1000: MMIO read took 317 clocks
e1000: MMIO read took 481 clocks
e1000: MMIO read took 337 clocks
e1000: MMIO read took 480 clocks
e1000: MMIO read took 316 clocks
e1000: MMIO read took 480 clocks
e1000: MMIO read took 409 clocks
e1000: MMIO read took 480 clocks
e1000: MMIO read took 334 clocks
e1000: MMIO read took 481 clocks
e1000: MMIO read took 316 clocks
e1000: MMIO read took 480 clocks
e1000: MMIO read took 11 clocks
e1000: MMIO read took 505 clocks
e1000: MMIO read took 359 clocks
e1000: MMIO read took 484 clocks
e1000: MMIO read took 337 clocks
e1000: MMIO read took 464 clocks
e1000: MMIO read took 504 clocks

/Martin
