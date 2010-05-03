From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 03 May 2010 07:17:14 +0200
Message-ID: <1272863834.2173.173.camel@edumazet-laptop>
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
	 <1272828143.2173.150.camel@edumazet-laptop>
	 <20100502205044.450beda2@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33319 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab0ECFRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 01:17:22 -0400
Received: by bwz19 with SMTP id 19so1088245bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 22:17:21 -0700 (PDT)
In-Reply-To: <20100502205044.450beda2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 20:50 -0700, Arjan van de Ven a =C3=A9cr=
it :

> we effectively do that. The thing is that C2 is so low cost normally
> that it's still worth it even at 20k wakeups...
>=20
> this is where the bios tells us how "heavy" the states are....
> and 64 usec... is just not very much.

Maybe its low cost, (apparently, it is, since I can reach ~900.000 ipis
on my 16 cores machine) but multiply this by 16 or 32 or 64 cpus, and
clockevents_notify() cost appears to be a killer, all cpus compete on a
single lock.

Maybe this notifier could use RCU ?


