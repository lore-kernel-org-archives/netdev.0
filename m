From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 1 Mar 2012 15:25:53 +0100
Message-ID: <A1249B08688639468D1CB181445EE79D5A61B30431@ESESSCMS0355.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "rodrigo.moya@collabora.co.uk" <rodrigo.moya@collabora.co.uk>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"javier@collabora.co.uk" <javier@collabora.co.uk>,
	"lennart@poettering.net" <lennart@poettering.net>,
	"kay.sievers@vrfy.org" <kay.sievers@vrfy.org>,
	"alban.crequy@collabora.co.uk" <alban.crequy@collabora.co.uk>,
	"bart.cerneels@collabora.co.uk" <bart.cerneels@collabora.co.uk>,
	"sjoerd.simons@collabora.co.uk" <sjoerd.simons@collabora.co.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
Have you considered using TIPC instead?
It already provides multicast messaging with guaranteed ordering, and r=
eliable delivery  (SOCK _RDM)

//E
=20

--Original message---
Sender: "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
Sent time: Thu Mar 01 14:56:00 CET 2012
To: eric.dumazet@gmail.com
Cc: rodrigo.moya@collabora.co.uk, David.Laight@ACULAB.COM, davem@daveml=
oft.net, javier@collabora.co.uk, lennart@poettering.net, kay.sievers@vr=
fy.org, alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk, sj=
oerd.simons@collabora.co.uk, netdev@vger.kernel.org, linux-kernel@vger.=
kernel.org
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features=
 to AF_UNIX

On 03/01/2012 01:59 PM, Eric Dumazet wrote:
> Le jeudi 01 mars 2012 =E0 13:50 +0100, Rodrigo Moya a =E9crit :
>> the main problem in D-Bus we are trying to solve is the context
>> switches, since right now, there is a daemon, which listens on a UNI=
X
>> socket, and all traffic in the bus goes through it, and then the dae=
mon
>> has to route the messages it gets on that socket to the correspondin=
g
>> place(s). So, every time someone sends a message to D-Bus, since all
>> traffic goes through the daemon, dbus-daemon gets waked-up, which is=
 one
>> of the biggest bottlenecks we are trying to fix.
>>=20
>> That's why we are thinking about using multicast with socket filters=
, so
>> that the daemon only gets traffic it cares about and thus is not wak=
ed
>> up and context switches don't happen when not needed.
>>=20
>> Using message queues, AFAICS, we would have the same problem, as the
>> daemon would create the message queue and would get all traffic, rig=
ht?
>>=20
>=20
> This is why I mentioned extensions.


>=20
> Anyway, if you think multicast sockets is the way to go, then you cou=
ld
> setup a virtual network just to be able to use AF_INET multicast.
>=20
> Thats probably doable without kernel patching.
>=20

We could use AF_INET multicast on a local machine but we need some
ordering and control flow requirements that are not guaranteed on UDP
multicast over IP. That's why we thought to add a new address family
AF_MCAST.

To make it a general local multicast solution and not being too specifi=
c
we added some flags to control its behavior like
MCAST_MREQ_DROP_WHEN_FULL to decide to either block the sender or drop
the packet when one receiver has its queue full.

Regards,
Javier
