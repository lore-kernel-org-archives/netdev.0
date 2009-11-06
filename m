From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 take2] ipv6: udp: Optimise multicast reception
Date: Fri, 06 Nov 2009 19:03:43 +0100
Message-ID: <4AF464FF.10609@gmail.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <4AF45BDE.4090501@gmail.com> <4AF462EF.1050604@gmail.com> <200911061959.57326.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	opurdila@ixiacom.com
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34956 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756654AbZKFSDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 13:03:43 -0500
In-Reply-To: <200911061959.57326.lgrijincu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucian Adrian Grijincu a =E9crit :
> =CEn data de Vin 06 Noi 2009 19:54:55 Eric Dumazet a scris:
>> We should atomic_inc(&sk->sk_drops) in the case skb_clone()
>> could not provide a copy, and eventually increment UDP_MIB_RCVBUFERR=
ORS &
>> UDP_MIB_INERRORS SNMP counters
>=20
> Shouldn't this be also done if udp_queue_rcv_skb() returned a failure=
 code (a=20
> positive number) instead of silently droping?
>=20

Nope, this is correctly done in __udp_queue_rcv_skb() & sock_queue_rcv_=
skb()

Only multicast is lazy in this area.
