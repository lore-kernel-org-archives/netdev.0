From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 26 Nov 2004 16:31:21 +0100
Message-ID: <1101483081.24742.174.camel@mellia.lipar.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <41A73826.3000109@draigBrady.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If you don't trust us, please, ignore this email.
Sorry.

That's the number we have. And are actually very similar from what other
colleagues of us got.

The point is:
while a PCI-X linux or (or click) box can receive (receive just up to
the netif_receive_skb() level and then discard the skb) up to more than
wire speed using off-the-shelf gigabit ethernet hardware, there is no
way to transmit more than about half that speed. This is true
considering minimum sized ethernet frames.

This holds true with=20
- linux 2.4.x and 2.6.x and click-linux 2.4.x
- intel e1000 or broadcom drivers (modified to drop packets after the=20
netif_receive_skb())
- whichever driver version you like (with minor modifications).

The only modification to the driver we did consists in carefully
prefecting the data in the CPU internal cache.

Some details and results can be retreived from

http://www.tlc-networks.polito.it/~mellia/euroTLC.pdf

Part of this results are presented in this paper
A. Bianco, J.M. Finochietto, G. Galante, M. Mellia, F. Neri
Open-Source PC-Based Software Routers: a Viable Approach to High-Performa=
nce Packet Switching
Third Internation Workshop on QoS in Multiservice IP Networks
Catania, Feb 2005
http://www.tlc-networks.polito.it/mellia/papers/Euro_qos_ip.pdf

Hope this helps.

> I'm forwarding this to netdev, as these are very interesting
> results (even if I don't beleive them).
>=20
> If you point us at the code/versions we will be better able to answer.
>=20
> Marco Mellia wrote:
> > We are trying to stress the e1000 hardware/driver under linux and Cli=
ck
> > to see what is the maximum number of packets per second that can be
> > received/transmitted by a single NIC.
> >=20
> > We found something which is counterintuitive:
> >=20
> > - in reception, we can receive ALL the traffic, regardeless of the
> > packet size (or if you prefer, we can receive ALL the minimum sized
> > packet at gigabit speed)
>=20
> I questioned whether you actually did receive at that rate to
> which you responded:
>=20
>  > - using Click, we can receive 100% of (small) packets at gigabit
>  >   speed with TWO cards (2gigabit/s ~ 2.8Mpps)
>  > - using linux and standard e1000 driver, we can receive up to about
>  >   80% of traffic from a single nic (~1.1Mpps)
>  > - using linux and a modified (simplified) version of the driver, we
>  >   can receive 100% on a single nic, but not 100% using two nics (up
>  >   to ~1.5Mpps).
>  >
>  > Reception means: receiving the packet up to the rx ring at the
>  > kernel level, and then IMMEDIATELY drop it (no packet processing,
>  > no forwarding, nothing more...)
>  >
>  > Using NAPI or IRQ has littel impact (as we are not processing the
>  > packets, the livelock due to the hardIRQ preemption versus the
>  > softIRQ managers is not entered...)
>  >
>  > But the limit in TRANSMISSION seems to be 700Kpps. Regardless of
>  > - the traffic generator,
>  > - the driver version,
>  > - the O.S. (linux/click),
>  > - the hardware (broadcom card have the same limit).
>=20
> >=20
> > - in transmission we CAN ONLY trasmit about 700.000 pkt/s when the
> > minimum sized packets are considered (64bytes long ethernet minumum
> > frame size). That is about HALF the maximum number of pkt/s consideri=
ng
> > a gigabit link.
> >=20
> > What is weird, is that if we artificially "preload" the NIC tx-fifo w=
ith
> > packets, and then instruct it to start sending them, those are actual=
ly
> > transmitted AT WIRE SPEED!!
> >=20
> > These results have been obtained considering different software
> > generators (namely, UDPGEN, PACKETGEN, Application level generators)
> > under LINUX (2.4.x, 2.6.x), and under CLICK (using a modified version=
 of
> > UDPGEN).
> >=20
> > The hardware setup considers=20
> > - a 2.8GHz Xeon hardware
> > - PCI-X bus (133MHz/64bit)
> > - 1G of Ram
> > - Intel PRO 1000 MT single, double, and quad cards, integrated or on =
a
> > PCI slot.
> >=20
> > Different driver versions have been used, and while there are (small)
> > differencies when receiving packets, ALL of them present the same
> > trasmission limits.
> >=20
> > Moreover, the same happen considering other vendors cards (broadcom
> > based chipset).
> >=20
> > Is there any limit on the PCI-X (or PCI) that can be the bottleneck?
> > Or Limit on the number of packets per second that can be stored in th=
e
> > NIC tx-fifo?
> > May the lenght of the tx-fifo impact on this?
> >=20
> > Any hints will be really appreciated.
> > Thanks in advance
>=20
> cheers,
> P=E1draig.
--=20
Ciao,                    /\/\/\rco

+-----------------------------------+ =20
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
