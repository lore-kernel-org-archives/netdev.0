From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 21:23:10 +0100
Message-ID: <1296073390.2631.4.camel@edumazet-laptop>
References: <1296062517.2899.86.camel@edumazet-laptop>
	 <1296063823.6115.37.camel@Joe-Laptop>
	 <20110126.115530.226756606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe@perches.com, netdev@vger.kernel.org, john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59666 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab1AZUXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 15:23:15 -0500
Received: by wyb28 with SMTP id 28so1338995wyb.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 12:23:14 -0800 (PST)
In-Reply-To: <20110126.115530.226756606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 11:55 -0800, David Miller a =C3=A9cr=
it :
> From: Joe Perches <joe@perches.com>
> >=20
> > I think the best style to use memset so that any
> > possible struct padding is guaranteed to be zeroed.
>=20
> Such padding does not exist, and we won't add such padding since this=
 is
> a user visible data structure and thus whose layout is cast in stone.
>=20
> Anyways, I'm ambivalent to how this is fixed actually.

I am perfectly aware of this ugly memset() style some people prefer, an=
d
5 % of the time they swap 2nd and 3rd param.

Two patches instead of one ;)

In this particular case, I only used existing codestyle: In the same
file I noticed :

vi +322 net/sched/sch_mqprio.c

static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
                               struct gnet_dump *d)
{
        struct net_device *dev =3D qdisc_dev(sch);

        if (cl <=3D netdev_get_num_tc(dev)) {
                int i;
                struct Qdisc *qdisc;
                struct gnet_stats_queue qstats =3D {0};
                struct gnet_stats_basic_packed bstats =3D {0};
                struct netdev_tc_txq tc =3D dev->tc_to_txq[cl - 1];




