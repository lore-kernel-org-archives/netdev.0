From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 02 Dec 2004 18:31:30 +0100
Message-ID: <1102008690.19646.22.camel@mellia.lipar.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com> <16807.20052.569125.686158@robur.slu.se>
	 <1101484740.24742.213.camel@mellia.lipar.polito.it>
	 <41A76085.7000105@draigBrady.com>
	 <1101499285.1079.45.camel@jzny.localdomain>
	 <16811.8052.678955.795327@robur.slu.se>
	 <1101821501.1043.43.camel@jzny.localdomain>
	 <20041130134600.GA31515@xi.wantstofly.org>
	 <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
	 <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: birke@serveliper.polito.it, Lennert Buytenhek <buytenh@wantstofly.org>,
        jamal <hadi@cyberus.ca>, Robert Olsson <Robert.Olsson@data.slu.se>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-01 at 02:09, Scott Feldman wrote:
> Hey, turns out, I know some e1000 tricks that might help get the kpps
> numbers up.  
> 
> My problem is I only have a P4 desktop system with a 82544 nic running
> at PCI 32/33Mhz, so I can't play with the big boys.  But, attached is a
> rework of the Tx path to eliminate 1) Tx interrupts, and 2) Tx
> descriptor write-backs.  For me, I see a nice jump in kpps, but I'd like
> others to try with their setups.  We should be able to get to wire speed
> with 60-byte packets.
> 

Here are the numbers in our setup:

vanilla kernel [2.4.20 + packetgen + driver e1000 5.4.11]
4096 Descr => 356 Mbps (60 bytes long frames)
           => 941Mbps (1500 bytes lonf frames)

256 Descr => 354 Mbps (60 bytes long frames)
           => 941Mbps (1500 bytes lonf frames)

Patched driver [2.4.20 + packetgen + driver e1000 5.4.11 patched]
4096 Descr => 357 Mbps (60 bytes long frames)
           => 941Mbps (1500 bytes lonf frames)

I guess that was _not_ the bottleneck sigh... at least with a PCI-X bus.
Again, latency issue of the DMA transfer from RAM to NIC?

-- 
Ciao,                    /\/\/\rco

+-----------------------------------+  
| Marco Mellia - Assistant Professor|
| Tel: 39-011-2276-608              |
| Tel: 39-011-564-4173              |
| Cel: 39-340-9674888               |   /"\  .. . . . . . . . . . . . .
| Politecnico di Torino             |   \ /  . ASCII Ribbon Campaign  .
| Corso Duca degli Abruzzi 24       |    X   .- NO HTML/RTF in e-mail .
| Torino - 10129 - Italy            |   / \  .- NO Word docs in e-mail.
| http://www1.tlc.polito.it/mellia  |        .. . . . . . . . . . . . .
+-----------------------------------+
The box said "Requires Windows 95 or Better." So I installed Linux.
