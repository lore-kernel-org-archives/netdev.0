From: P@draigBrady.com
Subject: Re: [E1000-devel] Transmission limit
Date: Fri, 26 Nov 2004 14:05:26 +0000
Message-ID: <41A73826.3000109@draigBrady.com>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mellia@prezzemolo.polito.it
In-Reply-To: <1101467291.24742.70.camel@mellia.lipar.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm forwarding this to netdev, as these are very interesting
results (even if I don't beleive them).

If you point us at the code/versions we will be better able to answer.

Marco Mellia wrote:
> We are trying to stress the e1000 hardware/driver under linux and Click
> to see what is the maximum number of packets per second that can be
> received/transmitted by a single NIC.
>=20
> We found something which is counterintuitive:
>=20
> - in reception, we can receive ALL the traffic, regardeless of the
> packet size (or if you prefer, we can receive ALL the minimum sized
> packet at gigabit speed)

I questioned whether you actually did receive at that rate to
which you responded:

 > - using Click, we can receive 100% of (small) packets at gigabit
 >   speed with TWO cards (2gigabit/s ~ 2.8Mpps)
 > - using linux and standard e1000 driver, we can receive up to about
 >   80% of traffic from a single nic (~1.1Mpps)
 > - using linux and a modified (simplified) version of the driver, we
 >   can receive 100% on a single nic, but not 100% using two nics (up
 >   to ~1.5Mpps).
 >
 > Reception means: receiving the packet up to the rx ring at the
 > kernel level, and then IMMEDIATELY drop it (no packet processing,
 > no forwarding, nothing more...)
 >
 > Using NAPI or IRQ has littel impact (as we are not processing the
 > packets, the livelock due to the hardIRQ preemption versus the
 > softIRQ managers is not entered...)
 >
 > But the limit in TRANSMISSION seems to be 700Kpps. Regardless of
 > - the traffic generator,
 > - the driver version,
 > - the O.S. (linux/click),
 > - the hardware (broadcom card have the same limit).

>=20
> - in transmission we CAN ONLY trasmit about 700.000 pkt/s when the
> minimum sized packets are considered (64bytes long ethernet minumum
> frame size). That is about HALF the maximum number of pkt/s considering
> a gigabit link.
>=20
> What is weird, is that if we artificially "preload" the NIC tx-fifo wit=
h
> packets, and then instruct it to start sending them, those are actually
> transmitted AT WIRE SPEED!!
>=20
> These results have been obtained considering different software
> generators (namely, UDPGEN, PACKETGEN, Application level generators)
> under LINUX (2.4.x, 2.6.x), and under CLICK (using a modified version o=
f
> UDPGEN).
>=20
> The hardware setup considers=20
> - a 2.8GHz Xeon hardware
> - PCI-X bus (133MHz/64bit)
> - 1G of Ram
> - Intel PRO 1000 MT single, double, and quad cards, integrated or on a
> PCI slot.
>=20
> Different driver versions have been used, and while there are (small)
> differencies when receiving packets, ALL of them present the same
> trasmission limits.
>=20
> Moreover, the same happen considering other vendors cards (broadcom
> based chipset).
>=20
> Is there any limit on the PCI-X (or PCI) that can be the bottleneck?
> Or Limit on the number of packets per second that can be stored in the
> NIC tx-fifo?
> May the lenght of the tx-fifo impact on this?
>=20
> Any hints will be really appreciated.
> Thanks in advance

cheers,
P=E1draig.
