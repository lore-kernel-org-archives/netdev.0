From: jamal <hadi@cyberus.ca>
Subject: Re: [E1000-devel] Transmission limit
Date: 26 Nov 2004 15:01:25 -0500
Message-ID: <1101499285.1079.45.camel@jzny.localdomain>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com> <16807.20052.569125.686158@robur.slu.se>
	 <1101484740.24742.213.camel@mellia.lipar.polito.it>
	 <41A76085.7000105@draigBrady.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mellia@prezzemolo.polito.it, Robert Olsson <Robert.Olsson@data.slu.se>,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <41A76085.7000105@draigBrady.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-11-26 at 11:57, P@draigBrady.com wrote:

> > skb are de/allocated using standard kernel memory management. Still,
> > without touching the packet, we can receive 100% of them.
> 
> I was doing some playing in this area this week.
> I changed the alloc per packet to a "realloc" per packet.
> I.E. the e1000 driver owns the packets. I noticed a
> very nice speedup from this. In summary a userspace
> app was able to receive 2x250Kpps without this patch,
> and 2x490Kpps with it. The patch is here:
> http://www.pixelbeat.org/tmp/linux-2.4.20-pb.diff

A very angry gorilla on that url ;->

> Note 99% of that patch is just upgrading from
> e1000 V4.4.12-k1 to V5.2.52 (which doesn't affect
> the performance).
> 
> Wow I just read you're excellent paper, and noticed
> you used this approach also :-)
> 

Have to read the paper - When Robert was last visiting here; we did some
tests and packet recycling is not very valuable as far as SMP is
concerned (given that packets can be alloced on one CPU and freed on
another). There a clear win on single CPU machines.

> >> Small packet performance is dependent on low latency. Higher bus speed
> >> gives shorter latency but also on higher speed buses there use to be  
> >> bridges that adds latency.
> > 
> > That's true. We suspect that the limit is due to bus latency. But still,
> > we are surprised, since the bus allows to receive 100%, but to transmit
> > up to ~50%. Moreover the raw aggerate bandwidth of the buffer is _far_
> > larger (133MHz*64bit ~ 8gbit/s
> 
> Well there definitely could be an asymmetry wrt bus latency.
> Saying that though, in my tests with much the same hardware
> as you, I could only get 800Kpps into the driver.

Yep, thats about the number i was seeing as well in both pieces of
hardware i used in the tests in my SUCON presentation.

>  I'll
> check this again when I have time. Note also that as I understand
> it the PCI control bus is running at a much lower rate,
> and that is used to arbitrate the bus for each packet.
> I.E. the 8Gb/s number above is not the bottleneck.
> 
> An lspci -vvv for your ethernet devices would be useful
> Also to view the burst size: setpci -d 8086:1010 e6.b
> (where 8086:1010 is the ethernet device PCI id).
> 

Can you talk a little about this PCI control bus? I have heard you
mention it before ... I am trying to visualize where it fits in PCI
system.

cheers,
jamal
