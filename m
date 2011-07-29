From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP forwarding regression since 3.0-rc6
Date: Fri, 29 Jul 2011 09:33:29 +0200
Message-ID: <1311924809.7845.29.camel@edumazet-laptop>
References: <20110725T141145.GA.2ae38.stse@fsing.rootsland.net>
	 <201107281546.33227.maciej.rutecki@gmail.com>
	 <20110729T091342.GA.06bf4.stse@fsing.rootsland.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Stephan Seitz <stse+lkml@fsing.rootsland.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110729T091342.GA.06bf4.stse@fsing.rootsland.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 juillet 2011 =C3=A0 09:15 +0200, Stephan Seitz a =C3=A9c=
rit :
> On Thu, Jul 28, 2011 at 03:46:33PM +0200, Maciej Rutecki wrote:
> >I created a Bugzilla entry at
> >https://bugzilla.kernel.org/show_bug.cgi?id=3D40282
> >for your bug report, please add your address to the CC list in there=
, thanks!
>=20
> Thank you for creating a bug report for me. I have added my address t=
o=20
> the CC list.
>=20

CC netdev

I suspect your configuration is too complex, and maybe the only way to
track the bug is to perform a git bisection.

Your initial message was :

Since 3.0-rc6 I see that my Linux router is losing packets. I can see=20
them tracing the internal interface, but I don=E2=80=99t see them on th=
e external=20
interface. I can reproduce the problem while using tin with=20
news.individual.de. At the startup when tin checks every newsgroup from=
=20
the server, many packets are suddenly not routed anymore but are droppe=
d,=20
so tin hangs until it quits with a NNTP error.
All kernels until 3.0-rc5 are working.

Hardware:
- 2x Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit=20
   Ethernet controller

Sofware:
- Debian Testing, 64bit, with Xen 4.1.0

System:
Dom0 (Debian Testing, 64bit) is my working system. The two NICs have ea=
ch=20
their own bridge interface. One bridge interface (A) has an internal IP=
=20
address (IPv4 and IPv6) of my internal network. The other bridge (B)=20
doesn=E2=80=99t have a IP address in Dom0. The DomU is connected to the=
 two=20
bridges.
DomU (Debian Testing, 64bit) is my iptables firewall system with Bind,=20
Squid, and other services. The interface connected to bridge A has an=20
internal IP addresses (gateway for my internal network). The interface=20
connected to bridge B is used for PPPoE (the NIC is directly connected =
to=20
my DSL modem).

Kernels:
Dom0 has had all kernel versions from 3.0-rcX and is running 3.0 at the=
=20
moment.
DomU has had the same kernel versions but is running 3.0-rc5 at the=20
moment because of the network problems in newer kernels.

Long problem description:
 From Dom0 I use tin to read different newsserver. One of them is=20
news.individual.de. The first time after DomU switched kernel to -rc6=20
I started tin (connecting to the mentioned news server) and tin hung=20
while reading groups from the newsrc and stopped with a NNTP connection=
=20
error.
Since the problem didn=E2=80=99t vanish, I wrote a mail to the support =
team of=20
the news server. They told me that I was the only one with a connection=
=20
problem and asked me to try the connection from another client. I tried=
=20
it from my vServer, and it worked. So the problem had to be in my setup=
=2E

I traced in Dom0 (bridge A), DomU (bridge A) und DomU (ppp0) and notice=
d=20
that all packets generated in Dom0 were visible in DomU bridge A. But n=
ot=20
all of the packets were visisble at the ppp0 interface. So my DomU was=20
dropping packets and the connection between tin in Dom0 and the news=20
server failed.

So I tried older kernels and noticed that 3.0-rc5 in DomU was working,=20
but rc6 and newer were not. The kernel configuration was the same for a=
ll=20
3.0 kernels.

Since I don=E2=80=99t know which maintainer I should contact with my pr=
oblem,=20
I=E2=80=99ll write directly to lkml.

Thanks for your help.

Shade and sweet water!

        Stephan
