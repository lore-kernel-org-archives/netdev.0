From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [NET_SCHED 03/06]: Fix endless loops caused by inaccurate qlen
 counters (part 1)
Date: Mon, 20 Nov 2006 18:07:51 +0200
Message-ID: <4561D2D7.20209@kolumbus.fi>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain> <20061120130840.22347.54563.sendpatchset@localhost.localdomain> <4561BA7B.4060005@kolumbus.fi> <4561BC31.5030405@trash.net> <4561BF44.4040801@kolumbus.fi> <4561C0DA.4080609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1.turkuamk.fi ([195.148.208.125]:15582 "EHLO
	mail-gw1.turkuamk.fi") by vger.kernel.org with ESMTP
	id S965978AbWKTQJt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 11:09:49 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4561C0DA.4080609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Mika Penttil=E4 wrote:
>  =20
>> Patrick McHardy wrote:
>>
>>    =20
>>> Mika Penttil=E4 wrote:
>>> =20
>>>
>>>      =20
>>>> Are you sure you didn't mean to :
>>>>
>>>> +    while ((parentid =3D sch->parent)) {
>>>> +        sch =3D __qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
>>>> +        cops =3D sch->ops->cl_ops;
>>>> +        if (!(sch->q.qlen -=3D n) && cops->qlen_notify) {    <---=
-
>>>>    =20
>>>>        =20
>>>
>>> We could do that, currently the qdiscs check themselves.
>>> The idea was mainly that they could be interested in
>>> other changes as well, for example for recalculating
>>> a deadline when the next packet in line changes.
>>>
>>>  =20
>>>      =20
>> But you call the notify before the decrement, which seems odd...
>>    =20
>
>
> The notification notifies of changes in a _child_ qdisc of
> the qdisc that is notified, which already has its counter
> decremented. The qdisc's own counter is irrelevant for
> the qdisc itself, it doesn't make any difference whether
> it is decremented before or after the notification.
>
> -
>  =20
Has already decremented where? As I read it you notify parent and=20
_after_ that decrement child's counter...
Also, shoudn't the return value of qdisc_lookup be check, I think it ca=
n=20
return NULL for default qdiscs.

--Mika


