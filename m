From: P@draigBrady.com
Subject: Re: [E1000-devel] Transmission limit
Date: Fri, 26 Nov 2004 16:57:41 +0000
Message-ID: <41A76085.7000105@draigBrady.com>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>	 <41A73826.3000109@draigBrady.com>  <16807.20052.569125.686158@robur.slu.se> <1101484740.24742.213.camel@mellia.lipar.polito.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mellia@prezzemolo.polito.it
In-Reply-To: <1101484740.24742.213.camel@mellia.lipar.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I forgot a smilely on my previous post
about not beleiving you. So here's 2: :-) :-)

Comments below:

Marco Mellia wrote:
> Robert,
> It a pleasure to hear from you.
>=20
>> Touching the packet-data givs a major impact. See eth_type_trans
>> in all profiles.

Notice the e1000 sets up the alignment for IP by default.

> skb are de/allocated using standard kernel memory management. Still,
> without touching the packet, we can receive 100% of them.

I was doing some playing in this area this week.
I changed the alloc per packet to a "realloc" per packet.
I.E. the e1000 driver owns the packets. I noticed a
very nice speedup from this. In summary a userspace
app was able to receive 2x250Kpps without this patch,
and 2x490Kpps with it. The patch is here:
http://www.pixelbeat.org/tmp/linux-2.4.20-pb.diff
Note 99% of that patch is just upgrading from
e1000 V4.4.12-k1 to V5.2.52 (which doesn't affect
the performance).

Wow I just read you're excellent paper, and noticed
you used this approach also :-)

>> Small packet performance is dependent on low latency. Higher bus speed
>> gives shorter latency but also on higher speed buses there use to be =20
>> bridges that adds latency.
>=20
> That's true. We suspect that the limit is due to bus latency. But still=
,
> we are surprised, since the bus allows to receive 100%, but to transmit
> up to ~50%. Moreover the raw aggerate bandwidth of the buffer is _far_
> larger (133MHz*64bit ~ 8gbit/s

Well there definitely could be an asymmetry wrt bus latency.
Saying that though, in my tests with much the same hardware
as you, I could only get 800Kpps into the driver. I'll
check this again when I have time. Note also that as I understand
it the PCI control bus is running at a much lower rate,
and that is used to arbitrate the bus for each packet.
I.E. the 8Gb/s number above is not the bottleneck.

An lspci -vvv for your ethernet devices would be useful
Also to view the burst size: setpci -d 8086:1010 e6.b
(where 8086:1010 is the ethernet device PCI id).

cheers,
P=E1draig.
