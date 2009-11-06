From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 take2] ipv6: udp: Optimise multicast reception
Date: Fri, 06 Nov 2009 18:54:55 +0100
Message-ID: <4AF462EF.1050604@gmail.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <4AF4506B.3080905@gmail.com> <4AF45796.8010409@gmail.com> <200911061919.47100.lgrijincu@ixiacom.com> <4AF45BDE.4090501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	opurdila@ixiacom.com
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59585 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755528AbZKFRy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:54:56 -0500
In-Reply-To: <4AF45BDE.4090501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
>
>=20
> Well, because of future RCU patch, I'll need to continue the loop any=
way,
> because sock_put() will be part of the loop.
>=20
> Also, the 'final' case will at least provide the skb we already have.
>=20

Last point :

We should atomic_inc(&sk->sk_drops) in the case skb_clone()
could not provide a copy, and eventually increment UDP_MIB_RCVBUFERRORS=
 &=20
UDP_MIB_INERRORS SNMP counters


