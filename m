From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 3 May 2010 03:22:27 -0700
Message-ID: <20100503032227.268613ac@infradead.org>
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
	<1272863834.2173.173.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53612 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab0ECKUX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 06:20:23 -0400
In-Reply-To: <1272863834.2173.173.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 May 2010 07:17:14 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le dimanche 02 mai 2010 =C3=A0 20:50 -0700, Arjan van de Ven a =C3=A9=
crit :
>=20
> > we effectively do that. The thing is that C2 is so low cost normall=
y
> > that it's still worth it even at 20k wakeups...
> >=20
> > this is where the bios tells us how "heavy" the states are....
> > and 64 usec... is just not very much.
>=20
> Maybe its low cost, (apparently, it is, since I can reach ~900.000
> ipis on my 16 cores machine) but multiply this by 16 or 32 or 64
> cpus, and clockevents_notify() cost appears to be a killer, all cpus
> compete on a single lock.
>=20
> Maybe this notifier could use RCU ?

could this be an artifact of the local apic stopping in deeper C states=
?
(which is finally fixed in the Westmere generation)



--=20
Arjan van de Ven 	Intel Open Source Technology Centre
=46or development, discussion and tips for power savings,=20
visit http://www.lesswatts.org
