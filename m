From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [E1000-devel] Transmission limit
Date: Fri, 26 Nov 2004 18:58:23 +0100
Message-ID: <16807.28351.85268.219176@robur.slu.se>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	<41A73826.3000109@draigBrady.com>
	<16807.20052.569125.686158@robur.slu.se>
	<1101484740.24742.213.camel@mellia.lipar.polito.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mellia@prezzemolo.polito.it
In-Reply-To: <1101484740.24742.213.camel@mellia.lipar.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Marco Mellia writes:

 > >  Touching the packet-data givs a major impact. See eth_type_trans
 > >  in all profiles.
 > 
 > That's exactly what we removed from the driver code: touching the packet
 > limit the reception rate at about 1.1Mpps, while avoiding to check the
 > eth_type_trans actually allows to receive 100% of packets.
 > 
 > skb are de/allocated using standard kernel memory management. Still,
 > without touching the packet, we can receive 100% of them.

 Right. I recall I tried something similar but as I only have pktgen
 as sender I could only verify this to pktgen TX speed about 860 kpps
 for PIII box I mentioned. This w. UP and one NIC.

 > When IP-forwarding is considered, no more we hit the transmission limit
 > (using NAPI, and your buffer recycling patch, as mentioned on the paper
 > and on the slides... If no buffer recycling is adopted, performance drop
 > a bit)
 > So it seemd to us that the major bottleneck is due to the transmission
 > limit.
 > 
 > Again, you can get numbers and more details from
 > 
 > http://www.tlc-networks.polito.it/~mellia/euroTLC.pdf
 > http://www.tlc-networks.polito.it/mellia/papers/Euro_qos_ip.pdf

 Nice. Seems we getting close to click w. NAPI and recycling. The skb
 recycling is outdated as it adds to much complexity to the kernel. I got 
 some idea how make a much more lighweight variant... If you feel hacking 
 I can outline the idea so you can try it.

 > >  OK. Good to know about e1000. Networking is most DMA's and CPU is used 
 > >  adminstating it this is the challange.
 > 
 > That's true. There is still the chance that the limit is due to hardware
 > CRC calculation (which must be added to the ethernet frame by the
 > nic...). But we're quite confortable that that is not the limit, since
 > in the reception path the same operation must be performed...

 OK!

 > >  Even you could try to fill TX as soon as the HW says there are available
 > >  buffers. This could even be done from TX-interrupt.
 > 
 > Are you suggesting to modify packetgen to be more aggressive?

 Well it could be useful at least as an experiment. Our lab would be 
 happy...

 > >  Small packet performance is dependent on low latency. Higher bus speed
 > >  gives shorter latency but also on higher speed buses there use to be  
 > >  bridges that adds latency.
 > 
 > That's true. We suspect that the limit is due to bus latency. But still,
 > we are surprised, since the bus allows to receive 100%, but to transmit
 > up to ~50%. Moreover the raw aggerate bandwidth of the buffer is _far_
 > larger (133MHz*64bit ~ 8gbit/s
 
 Have a look at graph in the pktgen paper presented at Linux-Kongress in
 Erlangen 2004. It seems like even at 8gbit/s thsi is limiting small 
 packet TX performance.

 ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/pktgen_paper.pdf 

						--ro
