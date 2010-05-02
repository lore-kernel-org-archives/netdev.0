From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 03 May 2010 00:08:24 +0200
Message-ID: <1272838104.2173.166.camel@edumazet-laptop>
References: <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
	 <1272797690.2173.26.camel@edumazet-laptop>
	 <20100502154649.GA18063@gargoyle.fritz.box>
	 <1272818131.2173.127.camel@edumazet-laptop>
	 <20100502212550.GA2673@gargoyle.fritz.box>
	 <1272836755.2173.153.camel@edumazet-laptop>
	 <20100502215450.GC2673@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:51083 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab0EBWIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 18:08:32 -0400
Received: by bwz19 with SMTP id 19so1009544bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 15:08:30 -0700 (PDT)
In-Reply-To: <20100502215450.GC2673@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 23:54 +0200, Andi Kleen a =C3=A9crit :
> On Sun, May 02, 2010 at 11:45:55PM +0200, Eric Dumazet wrote:

> > Tests just prove the reverse.
>=20
> What do you mean?=20
>=20

Test I did this week with Jamal.

We first set a "ee" rps mask, because all NIC interrupts were handled b=
y
CPU0, and Jamal thought like you, that not using cpu4 would give better
performance.

But using "fe" mask gave me a bonus, from ~700.000 pps to ~800.000 pps

CPU : E5450  @3.00GHz
Two quad-core cpus in the machine, tg3 NIC.

With RPS, CPU0 does not a lot of things, just talk with the NIC, bring =
a
few cache lines per packet and dispatch it to a slave cpu.



> HT (especially Nehalem HT) is useful for a wide range of workloads.
> Just handling network interrupts for its thread sibling is not one of=
 them.
>=20

Thats the theory, now in practice I see different results.

Of course, this might be related to hash distribution being different
and more uniform.

I should redo the test with many more flows.



