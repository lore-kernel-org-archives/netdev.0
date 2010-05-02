From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 02 May 2010 21:22:23 +0200
Message-ID: <1272828143.2173.150.camel@edumazet-laptop>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
	 <1272797690.2173.26.camel@edumazet-laptop>
	 <20100502071324.1a95fdad@infradead.org>
	 <1272810448.2173.31.camel@edumazet-laptop>
	 <20100502105418.7abf83a7@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33019 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab0EBTWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 15:22:32 -0400
Received: by bwz19 with SMTP id 19so963519bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 12:22:31 -0700 (PDT)
In-Reply-To: <20100502105418.7abf83a7@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 10:54 -0700, Arjan van de Ven a =C3=A9cr=
it :
> On Sun, 02 May 2010 16:27:28 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > C2 latency seems to be 64  (us ?), while C1 seems to be 1
>=20
> the processor_idle module has a "latency_factor" module parameter.
> The default is 2, but sometimes people think 6 is a better value...
> .. any chance you can try that value ?
>=20

I tried 6 and 20, nothing changed ;(

> Also, I'm starting to wonder if Andi's patch to use io_schedule() nee=
ds
> to be replaced with a net_schedule() kind of thing. The cpuidle code
> currently has a weight factor for IO (based on measuring/experiments)=
,
> and maybe networking really needs another factor... so just having a
> parallel concept with a different weight could be the right answer fo=
r
> that.
>=20

But a task blocked on disk IO is probably blocked for a small amount of
time, while on network, it can be for a long time. I am not sure its th=
e
right metric.

I was expecting something based on recent history.
Say if we have 20.000 wakeups per second, most likely we should not
enter C2/C3 states...

>=20
> we'll fix powertop to report the marketing name soon.
>=20
>=20

Ah, I see, thanks :)


