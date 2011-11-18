From: Rogier Wolff <R.E.Wolff@BitWizard.nl>
Subject: Re: Route cache problem.
Date: Fri, 18 Nov 2011 09:17:35 +0100
Message-ID: <20111118081734.GA25843@bitwizard.nl>
References: <20111103143734.GA17218@bitwizard.nl> <1320333410.2344.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1320333410.2344.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 03, 2011 at 04:16:50PM +0100, Eric Dumazet wrote:
> Le jeudi 03 novembre 2011 =E0 15:37 +0100, Rogier Wolff a =E9crit :
> > Hi,=20
> >=20
> > My workstation has an incorrect route cache entry:=20
> >=20
>=20
> What kernel version ?

Linux version 3.0.0-12-generic (from Ubunutu oneiric.)

> > assurancetourix:~> route -nC | head -2 ; route -nC | grep 234.34
> > Kernel IP routing cache
> > Source          Destination     Gateway         Flags Metric Ref   =
 Use Iface
> > 192.168.235.8   192.168.234.34  192.168.235.251       0      0     =
   3 eth0
> > 192.168.235.8   192.168.234.34  192.168.235.251       0      0     =
   4 eth0
> > 192.168.235.8   192.168.234.34  192.168.235.251       0      0     =
   2 eth0
> >=20
> > (I don't know why there are three).=20

Today there are four.=20
> 192.168.20.108  10.37.168.112   192.168.20.254        0      1       =
 2 eth3

That indeed got me a full complement of route cache entries.=20

> Better use "ip -s route list cache" to diagnose problems (more
> information)

After doing the tos ping you suggested All TOS levels have a route
cache entry.=20

192.168.234.34 from 192.168.235.8 tos 0x1c via 192.168.235.251 dev eth0=
=20
    cache <redirected>  age 77sec ipid 0xaa09 rtt 47ms rttvar 15ms ssth=
resh 7 cwnd 9
192.168.234.34 tos 0x1c via 192.168.235.251 dev eth0  src 192.168.235.8=
=20
    cache <redirected>  used 3 age 72sec ipid 0xaa09 rtt 47ms rttvar 15=
ms ssthresh 7 cwnd 9
192.168.234.34 from 192.168.235.8 tos 0x1c via 192.168.235.251 dev eth0=
=20
    cache <redirected>  age 72sec ipid 0xaa09 rtt 47ms rttvar 15ms ssth=
resh 7 cwnd 9

> > Any suggestions? Any at all?

Last time, as well as this time, it is triggered by a network error
that leads to the 192.168.235.4 router not being able to reach=20
192.168.234.34 or any other host on the 192.168.234.0/24 network.=20

During that time the VPN to 192.168.234.0/24 is down, so 192.168.235.4
doesn't have a route to 192.168.234.0/24 and it is logical that
with that route gone, it sends packets for 192.168.234.0/24 to the defa=
ult
router 192.168.235.251. As it sees itself forwarding packets that come
in on eth0 back to eth0, it will send a redirect. However that redirect
should somehow expire, and not survive things like dropping the route
to 192.168.234.0/24, dropping the default route, shutting down the=20
interface or some time passing (that network problem was solved 20=20
hours ago)......=20

	Roger.=20

--=20
** R.E.Wolff@BitWizard.nl ** http://www.BitWizard.nl/ ** +31-15-2600998=
 **
**    Delftechpark 26 2628 XH  Delft, The Netherlands. KVK: 27239233   =
 **
*-- BitWizard writes Linux device drivers for any device you may have! =
--*
The plan was simple, like my brother-in-law Phil. But unlike
Phil, this plan just might work.
