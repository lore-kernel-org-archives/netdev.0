From: P@draigBrady.com
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 14:59:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41484AC2.8090408@draigBrady.com>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>	<414808F3.70104@draigBrady.com> <16712.14153.683690.710955@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Harald Welte <laforge@netfilter.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16712.14153.683690.710955@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> P@draigBrady.com writes:
>  > Harald Welte wrote:
>=20
>  > > I'm currently trying to help Robert Olsson improving the performan=
ce of
>  > > the Linux in-kernel packet generator (pktgen.c).  At the moment, w=
e seem
>  > > to be unable to get more than 760kpps from a single port of a 8254=
6,
>  > > (or any other PCI-X MAC supported by e1000) - that's a bit more th=
an 51%
>  > > wirespeed at 64byte packet sizes.
>=20
>  Yes it seems intel adapters work better in BSD as they claim to route
>  1 Mpps and we cannot even send more ~750 kpps even with feeding the
>  adapter only. :-)
>=20
>  > In my experience anything around 750Kpps is a PCI limitation,
>  > specifically PCI bus arbitration latency. Note the clock speed of
>  > the control signal used for bus arbitration has not increased
>  > in proportion to the PCI data clock speed.
>=20
>  Yes data from an Opteron @ 1.6 GHz w. e1000 82546EB 64 byte pkts.
>=20
>  133 MHz 830 pps
>  100 MHz 721 pps
>   66 MHz 561 pps

Interesting info thanks!
It would be very interesting to see the performance of PCI express
which should not have the bus arbitration issues.

>  So higher bus bandwidth could increase the small packet rate.
>=20
>  So is there a difference in PCI-tuning BSD versus Linux?=20
>  And even more general can we measure the maximum numbers
>  of transactions on a PCI-bus?
>=20
>  Chip should be able to transfer 64 packets in single burst I don't now
>  how set/verify this.

Well from the intel docs they say "The devices include a PCI interface
that maximizes the use of bursts for efficient bus usage.
The controllers are able to cache up to 64 packet descriptors in
a single burst for efficient PCI bandwidth usage."

So I'm guessing that increasing the PCI-X burst size setting
(MMRBC) will automatically get more packets sent per transfer?
I said previously in this thread to google for setpci and MMRBC,
but what I know about it is...

To return the current setting(s):

setpci -d 8086:1010 e6.b

The MMRBC is the upper two bits of the lower nibble, where:

0 =3D 512 byte bursts
1 =3D 1024 byte bursts
2 =3D 2048 byte bursts
3 =3D 4096 byte bursts

For me to set 4KiB bursts I do:

setpci -d 8086:1010 e6.b=3D0e

The following measured a 30% throughput improvement (on 10G)
from setting the burst size to 4KiB:
https://mgmt.datatag.org/sravot/TCP_WAN_perf_sr061504.pdf

P=E1draig.
