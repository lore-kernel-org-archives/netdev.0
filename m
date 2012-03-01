From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 20:29:04 +0100
Message-ID: <4F4FCE00.6060302@collabora.co.uk>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E86@saturn3.aculab.com> <1330606237.27405.5.camel@megeve> <1330606775.2465.56.camel@edumazet-laptop> <4F4F7FFB.6010608@collabora.co.uk> <CABBYNZKN+7z4Sr9DBniokez6Jru02LxPgWdGNcVeYECse+AzEQ@mail.gmail.com> <CAL4WiiqjvA7iN8nydOx9tp8gOg1M_EDWKU5N+V5JFa90JbS8Ug@mail.gmail.com> <CAAwP0s3Awu9-d5KDgBEdSrNmAJraL0JRO+Z6XVgYk6LX4djKyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Luiz Augusto von Dentz <luiz.dentz@gmail.com>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Javier Martinez Canillas <martinez.javier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:53221 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab2CAT2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 14:28:20 -0500
In-Reply-To: <CAAwP0s3Awu9-d5KDgBEdSrNmAJraL0JRO+Z6XVgYk6LX4djKyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2012 08:02 PM, Javier Martinez Canillas wrote:
> On Thu, Mar 1, 2012 at 6:59 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>> Le 1 mars 2012 08:02, Luiz Augusto von Dentz <luiz.dentz@gmail.com> =
a =C3=A9crit :
>>>
>>> Contrary to someones believes I don't think AF_INET is that fast (e=
=2Eg.
>>> http://scottmoonen.com/2008/04/05/a-performance-comparison-of-af_un=
ix-with-loopback-on-linux/)
>>>
>>
>> Oh you mention a recent zork it seems ;)
>>
>> Are we speaking of performance problems, apart from scheduler proble=
ms
>> for D-Bus (each message wakeing all receivers, all receivers read an=
d
>> drop message but the target) ?
>>
>=20
> Hi Eric,
>=20
> The only performance problem we are talking about is the scheduling
> for D-bus (context switch to the daemon for each message). With today
> implementation the receivers only gets messages that were sent to it
> but the D-bus daemon has to be wake it up for every message to he can
> do the routing. For multicast messages (i.e: D-bus signals) this is
> even worse since the daemon has to do a send() for each receiver.
>=20
>> I am actually one of the few people working to improve performance o=
n
>> both AF_INET and AF_UNIX parts. Just take a look at recent commits.
>>
>> Right now you can send/receive millions of udp messages per second o=
n
>> your linux machine, if you figured out how to avoid process schedule=
r
>> costs. If D-Bus wants more, I highly suggest using shared memory
>> instead of passing messages.
>> --
>=20
> Yes, I also thought that AF_UNIX would be more efficient than AF_INET
> but I was wrong. Yesterday I wrote some tests using our multicast uni=
x
> socket, UDP multicast over IP on a single machine and even multicast
> using AF_NETLINK sockets and got very similar performance results.
>=20
> The only problem is the ordering and control flow requirements for D-=
bus.
>=20

And the fd passing for out-ouf-band communication used for some D-bus
application such as oFono and BlueZ.

Regards,
Javier
