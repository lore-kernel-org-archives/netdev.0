From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Sat, 4 Dec 2004 11:36:26 +0100
Message-ID: <20041204103626.GA17872@xi.wantstofly.org>
References: <1101484740.24742.213.camel@mellia.lipar.polito.it> <41A76085.7000105@draigBrady.com> <1101499285.1079.45.camel@jzny.localdomain> <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain> <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041203205706.GC9808@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Robert Olsson <Robert.Olsson@data.slu.se>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041203205706.GC9808@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Dec 03, 2004 at 09:57:06PM +0100, Lennert Buytenhek wrote:

> > My problem is I only have a P4 desktop system with a 82544 nic running
> > at PCI 32/33Mhz, so I can't play with the big boys.  But, attached is a
> > rework of the Tx path to eliminate 1) Tx interrupts, and 2) Tx
> > descriptor write-backs.  For me, I see a nice jump in kpps, but I'd like
> > others to try with their setups.  We should be able to get to wire speed
> > with 60-byte packets.
> 
> Attached is a graph of my numbers with and without your patch for:
> - An 82540 at PCI 32/33, idle 33MHz card on the same bus forcing it to 33MHz.
> - An 82541 at PCI 32/66.
> - An 82546 at PCI-X 64/100, NIC can do 133MHz but mobo only does 100MHz.

When extrapolating these numbers to the 0-byte packet case (which then
tells you the per-packet overhead), I get the following approximate numbers:

case				overhead 

phi-32-33-82540-2.6.9		1.86 us
phi-32-66-82541-2.6.9		1.41 us
phi-64-100-82546-2.6.9		1.45 us

phi-32-33-82540-2.6.9-feldman	1.48 us
phi-32-66-82541-2.6.9-feldman	1.13 us
phi-64-100-82546-2.6.9-feldman	1.25 us

Note that this figure doesn't differ all that much between the different
bus widths/speeds.

In any case, if I ever want to get more than ~880kpps on this hardware,
there's no other way than to make this overhead go down.  For saturating
1Gb/s with 60B packets on 64/100, the overhead can't be more than ~0.59 us
per packet or you lose.


--L
