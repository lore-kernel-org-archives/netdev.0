From: jamal <hadi@cyberus.ca>
Subject: Re: [E1000-devel] Transmission limit
Date: 26 Nov 2004 14:56:04 -0500
Message-ID: <1101498963.1076.39.camel@jzny.localdomain>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: P@draigBrady.com, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mellia@prezzemolo.polito.it
In-Reply-To: <1101483081.24742.174.camel@mellia.lipar.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-11-26 at 10:31, Marco Mellia wrote:
> If you don't trust us, please, ignore this email.
> Sorry.

Dont take it the wrong way please - nobody has been able to produce the
results you have. So thats why you may be getting that comment.
The fact you have been able to do this is a good thing.

> That's the number we have. And are actually very similar from what other
> colleagues of us got.
> 
> The point is:
> while a PCI-X linux or (or click) box can receive (receive just up to
> the netif_receive_skb() level and then discard the skb) up to more than
> wire speed using off-the-shelf gigabit ethernet hardware, there is no
> way to transmit more than about half that speed. This is true
> considering minimum sized ethernet frames.
> 

Hrm. I could not get more than 8-900Kpps on receive drop in the driver
on a super fast xeon. Can you post the diff for your driver?
My tests was with e1000.
What kind of hardware is this? Do you have a block diagram on how the
NIC is connected on the system? A lot of issues are dependent on how you
hardware hookup is.

> This holds true with 
> - linux 2.4.x and 2.6.x and click-linux 2.4.x
> - intel e1000 or broadcom drivers (modified to drop packets after the 
> netif_receive_skb())
> - whichever driver version you like (with minor modifications).
> 
> The only modification to the driver we did consists in carefully
> prefecting the data in the CPU internal cache.
> 

prefetching as in the use of prefetch()?
What were you prefetching if you end up dropping packet?

> Some details and results can be retreived from
> 
> http://www.tlc-networks.polito.it/~mellia/euroTLC.pdf
> 
> Part of this results are presented in this paper
> A. Bianco, J.M. Finochietto, G. Galante, M. Mellia, F. Neri
> Open-Source PC-Based Software Routers: a Viable Approach to High-Performance Packet Switching
> Third Internation Workshop on QoS in Multiservice IP Networks
> Catania, Feb 2005
> http://www.tlc-networks.polito.it/mellia/papers/Euro_qos_ip.pdf
> 
> Hope this helps.
> 

Thanks i will read these papers. 
Take a look at presentation i made at SUCON:
www.suug.ch/sucon/04/slides/pkt_cls.pdf
I have solved the problem which is identified in the first of slides
(just before "why me momma?" slide) - i could describe the solution and
even provide pathces which may address (perhaps) some of the transmit
issues you are seeing. 

cheers,
jamal
