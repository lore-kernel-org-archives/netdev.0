From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 03/06]: Fix endless loops caused by inaccurate qlen
 counters (part 1)
Date: Mon, 20 Nov 2006 15:51:06 +0100
Message-ID: <4561C0DA.4080609@trash.net>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain> <20061120130840.22347.54563.sendpatchset@localhost.localdomain> <4561BA7B.4060005@kolumbus.fi> <4561BC31.5030405@trash.net> <4561BF44.4040801@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:6022 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S934212AbWKTOvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 09:51:12 -0500
To: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <4561BF44.4040801@kolumbus.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mika Penttil=E4 wrote:
> Patrick McHardy wrote:
>=20
>> Mika Penttil=E4 wrote:
>> =20
>>
>>> Are you sure you didn't mean to :
>>>
>>> +    while ((parentid =3D sch->parent)) {
>>> +        sch =3D __qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
>>> +        cops =3D sch->ops->cl_ops;
>>> +        if (!(sch->q.qlen -=3D n) && cops->qlen_notify) {    <----
>>>    =20
>>
>>
>>
>> We could do that, currently the qdiscs check themselves.
>> The idea was mainly that they could be interested in
>> other changes as well, for example for recalculating
>> a deadline when the next packet in line changes.
>>
>>  =20
>=20
> But you call the notify before the decrement, which seems odd...


The notification notifies of changes in a _child_ qdisc of
the qdisc that is notified, which already has its counter
decremented. The qdisc's own counter is irrelevant for
the qdisc itself, it doesn't make any difference whether
it is decremented before or after the notification.

