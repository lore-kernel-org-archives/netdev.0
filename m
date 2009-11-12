From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Thu, 12 Nov 2009 13:48:54 +0100
Message-ID: <4AFC0436.9090906@gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFBD911.6000900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39329 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbZKLMs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 07:48:57 -0500
In-Reply-To: <4AFBD911.6000900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =A8=A6crit :
> ifb: add multi-queue support
>=20
> Add multi-queue support, and one kernel thread is created for per que=
ue.
> It can used to emulate multi-queue NIC in software, and distribute wo=
rk
> among CPUs.
> gentux linux # modprobe ifb numtxqs=3D2
> gentux linux # ifconfig ifb0 up
> gentux linux # pgrep ifb0
> 18508
> 18509
> gentux linux # taskset -p 1 18508
> pid 18508's current affinity mask: 3
> pid 18508's new affinity mask: 1
> gentux linux # taskset -p 2 18509
> pid 18509's current affinity mask: 3
> pid 18509's new affinity mask: 2
> gentux linux # tc qdisc add dev br0 ingress
> gentux linux # tc filter add dev br0 parent ffff: protocol ip basic
> action mirred egress redirect dev ifb0
>=20
> This patch also introduces a ip link option "numtxqs" for specifying =
the
> number of the TX queues. so you can add a new ifb with the command:
>=20
> ip link add numtxqs 4 type ifb
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----

I believe this patch is fine, but maybe Jarek concern about workqueue=20
vs tasklet should be addressed...

We could use the previous handling in case numtxqs=3D=3D1 , ie use a ta=
sklet
instead of a work queue ?


Sorry for this late idea...
