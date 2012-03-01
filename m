From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 08:00:40 -0800
Message-ID: <1330617640.2465.78.camel@edumazet-laptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E86@saturn3.aculab.com>
	  <1330606237.27405.5.camel@megeve>
	 <1330606775.2465.56.camel@edumazet-laptop>
	 <4F4F7FFB.6010608@collabora.co.uk>
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
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4F7FFB.6010608@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 01 mars 2012 =C3=A0 14:56 +0100, Javier Martinez Canillas a =C3=
=A9crit :

> We could use AF_INET multicast on a local machine but we need some
> ordering and control flow requirements that are not guaranteed on UDP
> multicast over IP. That's why we thought to add a new address family
> AF_MCAST.
>=20

It seems application logic and complexity pushed into kernel, for a ver=
y
single user (even if used in a lot of products) : D-Bus

> To make it a general local multicast solution and not being too speci=
fic
> we added some flags to control its behavior like
> MCAST_MREQ_DROP_WHEN_FULL to decide to either block the sender or dro=
p
> the packet when one receiver has its queue full.

I am only wondering how many lines this is going to add in kernel for a
complete implementation, given your performance expectations, flow
control, reliability, not counting all security issues (ancillary
messages and so on)

In case of IP_MULTICAST_LOOP, we could allow the sender to sleep if
receiver queue is full, with a bit of tweaking in stack (current
implementation uses loopback re-inject, so requires softirq handling).

In fact, we could use a new IP_MULTICAST_LOCAL option, so that sender
processing doesnt trigger a softirq handler at all and is allowed to
sleep if needed. For example skb allocations could use GFP_KERNEL
instead of current GFP_ATOMIC ones in udp mcast .

I dont know, maybe it would be a smaller patch.
