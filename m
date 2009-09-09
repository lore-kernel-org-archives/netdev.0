From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Wed, 09 Sep 2009 18:02:59 +0200
Message-ID: <4AA7D1B3.7010708@trash.net>
References: <20090906200409.GB8833@ami.dom.local> <4AA50A49.7010905@trash.net> <20090907192429.GC4451@ami.dom.local> <4AA563B4.1060003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40711 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbZIIQDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 12:03:02 -0400
In-Reply-To: <4AA563B4.1060003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
>> On Mon, Sep 07, 2009 at 03:27:37PM +0200, Patrick McHardy wrote:
>>> Jarek Poplawski wrote:
>> ...
>>>>> +static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
>>>>> +{
>>>>> +	struct net_device *dev =3D qdisc_dev(sch);
>>>>> +	struct Qdisc *qdisc;
>>>>> +	unsigned int ntx;
>>>>> +
>>>>> +	sch->q.qlen =3D 0;
>>>>> +	memset(&sch->bstats, 0, sizeof(sch->bstats));
>>>>> +	memset(&sch->qstats, 0, sizeof(sch->qstats));
>>>>> +
>>>>> +	for (ntx =3D 0; ntx < dev->num_tx_queues; ntx++) {
>>>>> +		qdisc =3D netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
>>>>> +		spin_lock_bh(qdisc_lock(qdisc));
>>>>> +		sch->q.qlen		+=3D qdisc->q.qlen;
>>>>> +		sch->bstats.bytes	+=3D qdisc->bstats.bytes;
>>>>> +		sch->bstats.packets	+=3D qdisc->bstats.packets;
>>>>> +		sch->qstats.qlen	+=3D qdisc->qstats.qlen;
>>>> Like in Christoph's case, we should probably use q.qlen instead.
>>> Its done a few lines above. This simply sums up all members of qsta=
ts.
>> AFAICS these members are updated only in tc_fill_qdisc, starting fro=
m
>> the root, so they might be not up-to-date at the moment, unless I mi=
ss
>> something.
>
> Yes, we might need an q->ops->update_stats(struct Qdisc *sch) method,=
 and
> to recursively call it from mq_update_stats()

Unless I'm missing something, that shouldn't be necessary since
sch->q.qlen contains the correct sum of all child qdiscs and
this is used by tc_fill_qdisc to update qstats.qlen.
