From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 29 Nov 2004 09:53:33 +0100
Message-ID: <1101718412.14930.46.camel@verza.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
	 <20041127092503.GA12592@sunbeam.de.gnumonks.org>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marco Mellia <mellia@prezzemolo.polito.it>, P@draigBrady.com,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20041127092503.GA12592@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-11-27 at 10:25, Harald Welte wrote:
> On Fri, Nov 26, 2004 at 04:31:21PM +0100, Marco Mellia wrote:
> > If you don't trust us, please, ignore this email.
> > Sorry.
> > 
> > That's the number we have. And are actually very similar from what other
> > colleagues of us got.
> > 
> > The point is:
> > while a PCI-X linux or (or click) box can receive (receive just up to
> > the netif_receive_skb() level and then discard the skb) up to more than
> > wire speed using off-the-shelf gigabit ethernet hardware, there is no
> > way to transmit more than about half that speed. This is true
> > considering minimum sized ethernet frames.
> 
> Yes, I've seen this, too.
> 
> I even rewrote the linux e1000 driver in order to re-fill the tx queue
> from hardirq handler, and it didn't help.  760kpps is the most I could
> ever get (133MHz 64bit PCI-X on a Sun Fire v20z, Dual Opteron 1.8GHz)
> 
> I've posted this result to netdev at some earlier point, I also Cc'ed
> intel but never got a reply
> (http://oss.sgi.com/archives/netdev/2004-09/msg00540.html)
> 
> My guess is that Intel always knew this and they want to sell their CSA
> chips rather than improving the PCI e1000.
> 
> We are hitting a hard limit here, either PCI-X wise or e1000 wise.  You
> cannot refill the tx queue faster than from hardirq, and still you don't
> get any better numbers.
> 
> It was suggested that the problem is PCI DMA arbitration latency, since
> the hardware needs to arbitrate the bus for every packet.

Th's our intuition too.
Notice that we get the same results with 3com (broadcom based) gigabit
cards.
We are thinking of sending packet in "bursts" instead of single
transfers. The only problem is to let the NIC know that there are more
than a packet in a burst...

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
