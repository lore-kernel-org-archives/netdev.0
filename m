From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] tc: report informations for multiqueue devices
Date: Wed, 02 Sep 2009 19:50:43 +0200
Message-ID: <4A9EB073.9030105@trash.net>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com>	<20090902.013002.181288977.davem@davemloft.net>	<4A9E6551.4030209@gmail.com>	<4A9E699B.7080400@gmail.com> <20090902092351.11649796@nehalam> <4A9E9D8A.50406@trash.net> <4A9EAC00.4030106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	cl@linux-foundation.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51544 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbZIBRur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 13:50:47 -0400
In-Reply-To: <4A9EAC00.4030106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> Just to avoid duplicate work - I'm currently trying to put a patch
>> together that presents multiqueue qdiscs to userspace as regular
>> child qdiscs of a dummy qdisc, which also contains the aggregated
>> statistics. So far it actually looks pretty sane :)
>=20
> There is one thing that bothers me with "tc -s -d qdisc", maybe
> its the right time to speak
>=20
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 54823 bytes 490 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc pfifo_fast 0: dev eth1 root bands 3 priomap  1 2 2 2 1 2 0 0 1 =
1 1 1 1 1 1 1
>  Sent 468 bytes 6 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
>=20
>=20
> The rate estimation is given by kernel even if no rate estimation is =
performed.
>=20
> User space doesnt have an indication saying this 0 numbers are real o=
r fake
> (rate 0bit 0pps).
>=20
> Could we set a bit at Qdisc level when a gen_new_estimator() is reall=
y
> done one a Qdisc, so that we do not call gnet_stats_copy_rate_est()
> from tc_fill_qdisc() if this bit is not set ?

That should be possible, I'll look into it once I've finished my patch.
