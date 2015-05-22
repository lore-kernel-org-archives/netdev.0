From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: ingress policying for realtime protocol
Date: Fri, 22 May 2015 10:00:59 -0400
Message-ID: <555F369B.2000703@mojatatu.com>
References: <20150519211145.GA23134@pengutronix.de> <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com> <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com> <20150521070712.GY24769@pengutronix.de> <555DDF5C.8080503@mojatatu.com> <20150521185831.GC24769@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>
To: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:35770 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756896AbbEVOBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 10:01:07 -0400
Received: by iesa3 with SMTP id a3so31853938ies.2
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 07:01:06 -0700 (PDT)
In-Reply-To: <20150521185831.GC24769@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/21/15 14:58, Uwe Kleine-K=F6nig wrote:
> Hello,
>

> My picture of the network stack might be wrong, but if the ethernet
> driver queues say 5 packets to the network stack and the fourth is a =
MRP
> packet than a priorization that makes the fourth packet processed fir=
st
> would be nice.
 >
> If there is no queue and the first packet is processed before the
> ethernet driver has a chance to hand over the second obviously there =
is
> no benefit from using a prio queue because it would always only conta=
in
> a single packet.
>

Yes. If these packets arrived at about the same time then i think
good MRP friendly hardware should hand over the MRP packet first ahead
of some of the other ones. Then you really dont need a queue.
Otherwise you are compensating for this hardware not being smart enough=
=2E

Only scenario i can think of where a queue would be useful is if
the (host) system is overloaded. I think NAPI would pull up to N
packets and queue them to something like ifb. Later when the tasklet
is run they would be  re-injected back to the stack.

> The 100kbit limit was found by starting with a higher limit and
> decrement while scp still made the MRP hiccup. Now what's wrong: It's
> annoying that other traffic is cut down that much.
>

I think from that perspective I like Eric's script, except i would
modify it to use simple pfifo i.e shaping is not really necessary
but as you experiment you may reach a different conclusion.

> There is only a single port involved but that one is connected to a
> Marvell switch. So the packets all come in on eth0 but the userspace
> application that handles the MRP stuff still knows on which port of t=
he
> switch the packet came in. Also the blocking of a port is done with
> configuration of the switch. Does this answer your question?
>

Hrm. So eth0 is a management/control port? I thought this was a speacia=
l
MRP kind of hardware. And if am not mistaken the switch is just driven
by classical STP state of blocking/forwarding etc. So other than the
control packets showing up on out of band port this looks and smells
like STP. i.e this is just vanilla off the shelf switch ASIC with no
MRP specialization.


cheers,
jamal
