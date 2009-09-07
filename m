From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 21:49:08 +0200
Message-ID: <4AA563B4.1060003@gmail.com>
References: <20090906200409.GB8833@ami.dom.local> <4AA50A49.7010905@trash.net> <20090907192429.GC4451@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52781 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbZIGTtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 15:49:12 -0400
In-Reply-To: <20090907192429.GC4451@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Mon, Sep 07, 2009 at 03:27:37PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
> ...
>>>> +static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
>>>> +{
>>>> +	struct net_device *dev =3D qdisc_dev(sch);
>>>> +	struct Qdisc *qdisc;
>>>> +	unsigned int ntx;
>>>> +
>>>> +	sch->q.qlen =3D 0;
>>>> +	memset(&sch->bstats, 0, sizeof(sch->bstats));
>>>> +	memset(&sch->qstats, 0, sizeof(sch->qstats));
>>>> +
>>>> +	for (ntx =3D 0; ntx < dev->num_tx_queues; ntx++) {
>>>> +		qdisc =3D netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
>>>> +		spin_lock_bh(qdisc_lock(qdisc));
>>>> +		sch->q.qlen		+=3D qdisc->q.qlen;
>>>> +		sch->bstats.bytes	+=3D qdisc->bstats.bytes;
>>>> +		sch->bstats.packets	+=3D qdisc->bstats.packets;
>>>> +		sch->qstats.qlen	+=3D qdisc->qstats.qlen;
>>> Like in Christoph's case, we should probably use q.qlen instead.
>> Its done a few lines above. This simply sums up all members of qstat=
s.
>=20
> AFAICS these members are updated only in tc_fill_qdisc, starting from
> the root, so they might be not up-to-date at the moment, unless I mis=
s
> something.
>=20

Yes, we might need an q->ops->update_stats(struct Qdisc *sch) method, a=
nd
to recursively call it from mq_update_stats()

