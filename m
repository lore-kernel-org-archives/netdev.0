From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] macvlan: add multiqueue capability
Date: Thu, 03 Sep 2009 20:22:45 +0200
Message-ID: <4AA00975.20701@trash.net>
References: <4A9F9661.7020301@gmail.com> <4AA002BC.3050507@trash.net> <4AA00634.7050103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45013 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756099AbZICSWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 14:22:45 -0400
In-Reply-To: <4AA00634.7050103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> The patch looks fine, but it just occured to me that this won't
>> have any effect since both VLAN and macvlan use a tx_queue_len of 0,
>> so they will by default have queueing disabled. In fact this
>> will increase costs for the default case since we're now hashing
>> every packet.
>=20
> Good point !
>=20
> We'll have to hash the packet later when hitting the lowerdevice,
> which is multiqueue. No ?

Right. But we don't reuse that decision from what I can tell.

> Also, what's wrong with
>=20
> ip link add link eth0 eth0.103 txqueuelen 100 type vlan id 103

There's nothing wrong, but its kind of pointless since with the
default qdisc the queue will be bypassed, other qdiscs are shared
between the queues and defeat multiqueue.

I guess it could make sense if you want to apply TC actions
or something like that once we support using different (non-shared)
qdiscs for each queue.
