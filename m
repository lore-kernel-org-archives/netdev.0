From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: xfrm: is pmtu broken with ESP tunneling?
Date: Thu, 13 Feb 2014 01:01:15 +0100
Message-ID: <20140213000115.GH11150@order.stressinduktion.org>
References: <52F890D2.2060109@odi.ch> <20140211023258.GC11150@order.stressinduktion.org> <52FA8618.5030509@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ortwin =?utf-8?B?R2zDvGNr?= <odi@odi.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52FA8618.5030509@odi.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 11, 2014 at 09:20:40PM +0100, Ortwin Gl=C3=BCck wrote:
> On 02/11/2014 03:32 AM, Hannes Frederic Sowa wrote:
> >>net.ipv4.ip_no_pmtu_disc=3D1.
> >
> >This setting will shrink the path mtu to min_pmtu when a frag needed=
 icmp=20
> >is
> >received.
>=20
> The UDP+ESP encapsulation adds 60 bytes to the original packet size.
>=20
> ifconfig wla0 shows an mtu of 1500.
>=20
> The size of the first big packet on the interface:
> net.ipv4.ip_no_pmtu_disc=3D1: packet length is 1300
> net.ipv4.ip_no_pmtu_disc=3D0: packet length is 1500
>=20
> Length is without the ESP wrapper and UDP encapsulation. The packets =
are so=20
> big that they can't even leave the wireless interface and never show =
up on=20
> the router. So no ICMP packets are received. PMTU can't work with ini=
tial=20
> packets of that size.
>=20
> dump question: which layer discard these packets? qdisc? why no=20
> notification to the sender?

Could you try either dropwatch or perf script net_dropmonitor and flood=
 the
network with the problematic packets. From the traces we could see wher=
e the
packets get dropped without notification in the kernel.

> When I increase the mtu of the interface to 2000 with ifconfig, then =
I=20
> start seeing ICMP fragmentation needed from the next hop, indicating =
1500=20
> as the mtu as response to a 1560 byte UDP[ESP] packet.
>=20
> The next UDP[ESP] packet is shorter: 1360 bytes. It gets hard to see =
what's=20
> going on after that, but the connection is still not working.
>=20
> So, instead of somehow losing these packets on the way out of the int=
erface=20
> should the kernel not start with a lower mtu in the first place? Now =
it=20
> seems it is trying with the maximum of the interface and expecting to=
 scale=20
> down with pmtu - which can ever happen.
>=20
> >Can you send a ip route get <ip> to the problematic target to see ho=
w
> >far off the calculated value is?
>=20
> That command doesn't return anything useful. No hint on the mtu here.
>=20
> BTW, instead of disabling pmtu, setting mtu explicitly also helps:
> ip route add 10.6.6.0/24 via ${localip} mtu 1300

Strange that the problem disappears if you enable no_pmtu_disc then.

Thanks,

  Hannes
