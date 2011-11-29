From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 17:24:58 +0100
Message-ID: <CAA93jw7+KyX=7DC88hKisgaFtzn9vgLsBfUWOGhSHHPadw97Cg@mail.gmail.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	<CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	<1322550138.2970.70.camel@edumazet-laptop>
	<4ED4885F.8060309@intel.com>
	<CAA93jw7prPymGuWdn0pgHXL81g19opm2=-T4msy-b_s2MJ9=Jw@mail.gmail.com>
	<1322556234.2970.84.camel@edumazet-laptop>
	<CAA93jw6bvzASrtvjhKL+haZb0VEPvQQD0guf7aBTPxJbxydEAg@mail.gmail.com>
	<1322578667.2465.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Tom Herbert <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:43758 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab1K2QY7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 11:24:59 -0500
Received: by vcbfk14 with SMTP id fk14so4779228vcb.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 08:24:59 -0800 (PST)
In-Reply-To: <1322578667.2465.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 3:57 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 29 novembre 2011 =E0 09:51 +0100, Dave Taht a =E9crit :
>
>> Perhaps I don't understand the gross effects of TSO very well, but i=
f you have
>> 100 streams coming from a server, destined to X different destinatio=
ns,
>> and you FQ to each on a per packet basis, you end up impacting the d=
ownstream
>> receive buffers throughout much less than if you send each stream as=
 a burst.
>
> TSO makes packets larger, to lower cpu use in different layers (netfi=
lter, qdisc, ...).
>
> Imagine you could have MSS=3D65000 on your ethernet wire.
>
> If you need to send a high prio packet while a prior big one is
> in-flight on a dumb device (a single TX FIFO), there is nothing you
> can do but wait last bit of big packet hit the wire.
>
> Even with one flow you lose. Hundred flows dont matter
> (as long as you have proper classification in Qdisc layer, of course)

People keep talking about 'prioritization' as if it can apply.

It doesn't. Prioritization and classification are nearly hopeless
exercises when you have high rate streams. It worked at low rates for
some traffic, but...

The focus for fixing bufferbloat is

               "better queueing"...

and what that translates out to is some form of

fair queuing

- at the moment I'm enthralled with QFQ btw -

coupled with some form of active queue management that works. (RED
used to work but was rather flawed - it's still better than the
alternative of drop tail)

It doesn't necessarily translate out to more unmanaged dumb queues, it
may translate
out to more *managed* queues.

I wouldn't mind TSO AT ALL if the hardware did some of the above
underneath it. I've heard some rumblings that that might happen.  We
spent all that engineering time making TCP go fast and minimized the
hardware impact of that - why not spend a little more time - in the
next generation of hw/sw - making TCP work *better* on the network?

Cisco did that in the 90s, what's so hard about trying now, in
software and/or hardware?

Now look, this thread has got way off the original topic, which was on
BQL, and BQL mostly rocks. The MIAD (as opposed to AIMD) controller in
it bothers me, but that can be looked at harder later.

and I want to go back to making it work on top of my testbed so I can
finally see models matching reality and vice versa and keep working on
producing demonstrable results

that can help fix some problems in software now for end users,
gateways, routers, servers, and data centers... reducing latencies
from trips around the moon to around your living room...

=2E..and get slammed into hardware someday, if there is ever market
demand for things like interactive video, gaming, or voice
applications that just work.

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
