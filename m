From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Fri, 14 Jan 2011 20:21:07 +0100
Message-ID: <1295032867.3977.1.camel@edumazet-laptop>
References: <1295021808.3937.110.camel@edumazet-laptop>
	 <20110114095201.4fc58a45@nehalam>
	 <1295028502.3937.116.camel@edumazet-laptop>
	 <20110114110342.4d95ad5b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56420 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab1ANTV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 14:21:29 -0500
Received: by wyb28 with SMTP id 28so3156891wyb.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 11:21:14 -0800 (PST)
In-Reply-To: <20110114110342.4d95ad5b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 janvier 2011 =C3=A0 11:03 -0800, Stephen Hemminger a =C3=
=A9crit :
> From Eric Dumazet <eric.dumazet@gmail.com>
>=20
> In commit 44b8288308ac9d (net_sched: pfifo_head_drop problem), we fix=
ed
> a problem with pfifo_head drops that incorrectly decreased
> sch->bstats.bytes and sch->bstats.packets
>=20
> Several qdiscs (CHOKe, SFQ, pfifo_head, ...) are able to drop a
> previously enqueued packet, and bstats cannot be changed, so
> bstats/rates are not accurate (over estimated)
>=20
> This patch changes the qdisc_bstats updates to be done at dequeue() t=
ime
> instead of enqueue() time. bstats counters no longer account for drop=
ped
> frames, and rates are more correct, since enqueue() bursts dont have
> effect on dequeue() rate.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> CC: Patrick McHardy <kaber@trash.net>
> CC: Jarek Poplawski <jarkao2@gmail.com>
> CC: jamal <hadi@cyberus.ca>
> ---
> sch_fifo now changed to use __qdisc_queue_drop_head which
> keeps correct statistics and is actually clearer.
>=20
> =20

Thanks for doing this Stephen, this version seems fine.


