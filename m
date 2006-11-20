From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 03/06]: Fix endless loops caused by inaccurate qlen
 counters (part 1)
Date: Mon, 20 Nov 2006 17:42:35 +0100
Message-ID: <4561DAFB.3000701@trash.net>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain> <20061120130840.22347.54563.sendpatchset@localhost.localdomain> <4561BA7B.4060005@kolumbus.fi> <4561BC31.5030405@trash.net> <4561BF44.4040801@kolumbus.fi> <4561C0DA.4080609@trash.net> <4561D2D7.20209@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55181 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S934262AbWKTQmi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 11:42:38 -0500
To: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <4561D2D7.20209@kolumbus.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mika Penttil=E4 wrote:
> Patrick McHardy wrote:
>=20
>>
>> The notification notifies of changes in a _child_ qdisc of
>> the qdisc that is notified, which already has its counter
>> decremented. The qdisc's own counter is irrelevant for
>> the qdisc itself, it doesn't make any difference whether
>> it is decremented before or after the notification.
>=20
> Has already decremented where? As I read it you notify parent and
> _after_ that decrement child's counter...

No, a qdisc is notified about a child, then has its own counter
decremented. The initial decrement of the first qdisc is done by
the caller.

In most cases it is actually done after the function call for
simplicity, but only when it doesn't matter - in all cases but
SFQ the call is done by a qdisc for its own child qdiscs, so
the first parent is the qdisc itself and it is known whether
it needs to be decremented in advance or now. All upper qdiscs
will always see the already decremented values for their childs.

> Also, shoudn't the return value of qdisc_lookup be check, I think it =
can
> return NULL for default qdiscs.

default qdiscs can't have children, so they are never looked up.

