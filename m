From: Andre Tomt <andre@skjellin.no>
Subject: IPv6 bugs introduced in 2.4.21
Date: 16 Jun 2003 21:50:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[PS, I'm not subscribed to netdev, CC would be nice - is there any way
to get subscribed?]

Hi

I mailed you guys a little while ago on the "unable to use
SOMENETWORK::0000 as a nexthop gateway" bug in 2.4.21-pre/rc a while
ago. It is still present in 2.4.21, rendering the "first" /128 of a
arbitrary prefixlen unusable - :0000. This is especially bad with /127
tunnels, rendering :0000 and :0001 unusable). But! There is one more
oddity in 2.4.21, not present in 2.4.20..

The lower part of a /127 network is somehow, strangely routed to lo -
observe..

* ed-gw1 configuration
running 2.4.21-s2 (internal vendor tree with megaraid, md and some
netdrv updates, but pristine behaves the same)

* relevant routing info
2001:730:3::1:2a/127 via :: dev aorta  proto kernel  metric 256  mtu 1480=
 advmss 1420

2a is Aorta's end of the /127, 2b is our end.


from a host behind some routers:

root@kvass ~ # traceroute6 2001:730:3::1:2a
traceroute to 2001:730:3::1:2a (2001:730:3::1:2a) from 2001:730:f:3::2, 3=
0 hops max, 16 byte packets
 1  slask-fe-1.ws.pasop.tomt.net (2001:730:f:3::1)  2.46 ms  0.543 ms  0.=
455 ms
 2  casablanca-fe-1.co.pasop.tomt.net (2001:730:f:7::1)  0.941 ms  0.622 =
ms  0.567 ms
 3  ed-gw1-si0-0.sand-osl.skjellin.net (2001:730:f:ffff::)  6.56 ms  5.17=
7 ms  5.087 ms
^-- hmmm. this was supposed to end at Aorta, not here.

root@kvass ~ # traceroute6 2001:730:3::1:2b
traceroute to 2001:730:3::1:2b (2001:730:3::1:2b) from 2001:730:f:3::2, 3=
0 hops max, 16 byte packets
 1  slask-fe-1.ws.pasop.tomt.net (2001:730:f:3::1)  0.797 ms  0.533 ms  0=
.455 ms
 2  casablanca-fe-1.co.pasop.tomt.net (2001:730:f:7::1)  1.077 ms  0.623 =
ms  0.558 ms
 3  skjellin-gw1.no.ipv6.aorta.net (2001:730:3::1:2b)  5.068 ms  18.271 m=
s  5.182 ms
^-- alright!

from ed-gw1:

root@ed-gw1 ~ # traceroute6 2001:730:3::1:2a
traceroute to 2001:730:3::1:2a (2001:730:3::1:2a) from ::1, 30 hops max, =
16 byte packets
 1  ip6-localhost (::1)  0.108 ms  0.099 ms  0.033 ms
^-- ehem.. this isn't Aorta, is it?

root@ed-gw1 ~ # traceroute6 2001:730:3::1:2b
traceroute to 2001:730:3::1:2b (2001:730:3::1:2b) from ::1, 30 hops max, =
16 byte packets
 1  skjellin-gw1.no.ipv6.aorta.net (2001:730:3::1:2b)  0.101 ms  0.089 ms=
  0.103 ms
^-- alright!




--=20
Mvh,
Andr=E9 Tomt
andre@skjellin.no
