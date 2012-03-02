From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Fri, 02 Mar 2012 17:34:50 +0100
Message-ID: <4F50F6AA.9050909@collabora.co.uk>
References: <CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>  <20120301.170848.432407217191581288.davem@davemloft.net>  <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>  <20120302.035509.1994457175982020283.davem@davemloft.net>  <4F509274.9060302@collabora.co.uk> <1330694031.2469.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	ying.xue@windriver.com, luiz.dentz@gmail.com,
	rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330694031.2469.15.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/2012 02:13 PM, Eric Dumazet wrote:
> Le vendredi 02 mars 2012 =C3=A0 10:27 +0100, Javier Martinez Canillas=
 a
> =C3=A9crit :
>=20
>> We are the most interested in using a facility already found in the
>> kernel, we will try ZeroMQ as Stephen suggested and TIPC but really
>> didn't find an IPC mechanism that fits our needs. The most important
>> issue right now is the fd passing for D-bus application doing
>> out-of-band communication.
>=20
> Why on earth the needed D-Bus IPC should use a single kernel mechanis=
m ?
>=20
> I mean, of course AF_INET cannot pass fd around and never will.
> Of course AF_UNIX cannot use multicast and never will.
> Of course shared memory wont pass fds around and never will.
> ... Add other impossible combinations as you want.
>=20
> There are reasons fd passing is hard to implement. I find stuffing th=
is
> functionality in AF_UNIX was a bad design choice from the very
> beginning.
>=20

Yes, can't say that everyone is happy with fd passing. It seems like a
workaround since D-bus didn't scale for big chunks of data IMHO.

> Instead of pushing extra complexity to a single kernel component, why
> not trying to use a combination of existing, well designed and suppor=
ted
> ones ?
>=20

You are right, maybe a combination of IPC mechanism could be used.

Basically we have this scenario:

1- Most applications today uses D-bus as an IPC system and is a central
part of the Linux desktop.

2- The transport layer used by D-bus is not performance sensitive
basically due:

a) high number of context switches required to send messages between pe=
er.
b) the D-bus daemon doing the routing and being a bottleneck of the who=
le.
c) amount of messages copied between kernel space and user space.

3- We still haven't found a single kernel IPC mechanism or a combinatio=
n
of IPC mechanism that can address this issue.

This is a real concern in the Linux embedded world. Since Linux based
products wants to use well probed software components found in Linux
distros such as oFono, BlueZ, Pulseaudio, Connman and Telepathy to name
a few. All of them uses D-bus to expose its API to other applications.

I'm not saying that extending AF_UNIX for supporting multicast is the
best approach but what I'm saying is that we should find a solution to
this problem.

PD: I'm cc'ing Marcel Holtmann so hopefully he can add his point of vie=
w
to the problem (and possible solutions).

I know that Marcel is also working on improving the D-bus system but
moving to the kernel some tasks made by the D-bus daemon today.

Regards,
Javier
