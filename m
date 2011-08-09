From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 1/9] dql: Dynamic queue limits
Date: Tue, 09 Aug 2011 10:56:41 +0200
Message-ID: <1312880201.2371.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1108072130380.13721@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43818 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab1HII4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:56:44 -0400
Received: by wyg24 with SMTP id 24so201092wyg.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 01:56:43 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108072130380.13721@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 07 ao=C3=BBt 2011 =C3=A0 21:43 -0700, Tom Herbert a =C3=A9c=
rit :
> Implementation of dynamic queue limits (dql).  This is a libary which
> allows a queue limit to be dynamically managed.  The goal of dql is
> to set the queue limit, number of ojects to the queue, to be minimize=
d
> without allowing the queue to be starved.
>=20
> dql would be used with a queue whose use has these properties:
>=20
> 1) Objects are queued up to some limit which can be expressed as a
>    count of objects.
> 2) Periodically a completion process executes which retires consumed
>    objects.
> 3) Starvation occurs when limit has been reached, all queued data has
>    actually been consumed but completion processing has not yet run,
>    so queuing new data is blocked.
> 4) Minimizing the amount of queued data is desirable.
>=20
> A canonical example of such a queue would be a NIC HW transmit queue.
>=20
> The queue limit is dynamic, it will increase or decrease over time
> depending on the workload.  The queue limit is recalculated each time
> completion processing is done.  Increases occur when the queue is
> starved and can exponentially increase over successive intervals.
> Decreases occur when more data is being maintained in the queue than
> needed to prevent starvation.  The number of extra objects, or "slack=
",
> is measured over successive intervals, and to avoid hysteresis the
> limit is only reduced by the miminum slack seen over a configurable
> time period.
>=20
> dql API provides routines to manage the queue:
> - dql_init is called to intialize the dql structure
> - dql_reset is called to reset dynamic structures
> - dql_queued when objects are being enqueued
> - dql_avail returns availability in the queue
> - dql_completed is called when objects have be consumed in the queue
>=20
> Configuration consists of:
> - max_limit, maximum limit
> - min_limt, minimum limit
> - slack_hold_time, time to measure instances of slack before reducing
>   queue limit.

Hi Tom

Not clear to me what value you use for slack_hold_time in your
benches/tests ?

Are you sure jiffy resolution (might be HZ=3D100) is precise enough for
future uses ?



