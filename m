From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 12:41:40 +0100
Message-ID: <4AF95174.3060104@trash.net>
References: <4AF924A5.1050303@gmail.com> <4AF92D6D.8060300@gmail.com>	 <412e6f7f0911100143k68284faes92e39d8ca94aa9d4@mail.gmail.com>	 <4AF9471C.5080606@gmail.com> <412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65283 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbZKJLlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 06:41:42 -0500
In-Reply-To: <412e6f7f0911100314i33d6a49dl5163b5e8472babcf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> 2009/11/10 Eric Dumazet <eric.dumazet@gmail.com>:
>> Changli Gao a =E9crit :
>>> 2009/11/10 Eric Dumazet <eric.dumazet@gmail.com>:
>>>> Not sure how to solve this problem (several cpus can updates count=
er in //)
>>>>
>>> Thanks, and follow your suggestions. I can maintain the counter per=
 TX
>>> queue, and update it in a timer handler like ixgbe or implement our
>>> own struct net_device_stats* (*ndo_get_stats)(struct net_device *de=
v),
>>> and update the counters when it gets called.
>> Please no timer stuff :)
>=20
> The whole ifb.c file is attached, please review and test it. Thanks!

> /* Number of TX queues per ifb */
> static int numtxqs =3D 1;
> module_param(numtxqs, int, 0444);
> MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");

Module parameters suck as a configuration API. The existing numifbs
option exists purely for compatibility reasons, I'd prefer if you'd
this to the netlink interface.

> static int __init ifb_init_one(int index)
> {
> 	struct net_device *dev_ifb;
> 	int err;
>=20
> 	dev_ifb =3D alloc_netdev_mq(sizeof(struct ifb_private) * numtxqs, "i=
fb%d",
> 				  ifb_setup, numtxqs);
>=20

This won't work for the rtnl_link setup since the size must
be constant.
