From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.33-rc5 regression] NULL pointer dereference in vlan_skb_recv
 - probably introduced by commit 9793241fe92f7d9303fb221e43fc598eb065f267
Date: Sun, 24 Jan 2010 14:42:54 +0100
Message-ID: <4B5C4E5E.2010507@gmail.com>
References: <20100123165657.187c11e4@neptune.home> <20100123223132.0e62d8cb@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56593 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102Ab0AXNnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 08:43:08 -0500
In-Reply-To: <20100123223132.0e62d8cb@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/01/2010 22:31, Bruno Pr=E9mont a =E9crit :
>> Above part of code did change between 2.6.32 and 2.6.33-rc5 with
>> commit 9793241fe92f7d9303fb221e43fc598eb065f267 (vlan: Precise RX
>> stats accounting)
>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=
=3Dcommitdiff;h=3D9793241fe92f7d9303fb221e43fc598eb065f267
>=20
> Reverting just that commit gets the system running correctly.
>=20
> Bruno

I have no idea how this patch can break vlan networking.

Your disassembly and .config seems to show your machine is not SMP

Maybe something is broken on UP and alloc_percpu() ?

Could you add a debug in vlan_dev_init()


 	vlan_dev_info(dev)->vlan_rx_stats =3D alloc_percpu(struct vlan_rx_sta=
ts);
	if (!vlan_dev_info(dev)->vlan_rx_stats)
 	return -ENOMEM;
+	pr_err("vlan_dev_init() rx_stats=3D%p\n", vlan_dev_info(dev)->vlan_rx=
_stats);


This make sure vlan_dev_init() is called and percpu allocation is prope=
rly done.

Thanks
