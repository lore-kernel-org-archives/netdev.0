From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 14:56:11 +0100
Message-ID: <4F4F7FFB.6010608@collabora.co.uk>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E86@saturn3.aculab.com>  <1330606237.27405.5.camel@megeve> <1330606775.2465.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330606775.2465.56.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/01/2012 01:59 PM, Eric Dumazet wrote:
> Le jeudi 01 mars 2012 =C3=A0 13:50 +0100, Rodrigo Moya a =C3=A9crit :
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
