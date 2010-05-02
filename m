From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 02 May 2010 18:35:31 +0200
Message-ID: <1272818131.2173.127.camel@edumazet-laptop>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
	 <1272797690.2173.26.camel@edumazet-laptop>
	 <20100502154649.GA18063@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:39832 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757293Ab0EBQfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 12:35:39 -0400
Received: by bwz19 with SMTP id 19so914336bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 09:35:37 -0700 (PDT)
In-Reply-To: <20100502154649.GA18063@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 17:46 +0200, Andi Kleen a =C3=A9crit :
> > In this test, all 16 queues of one BCM57711E NIC (1Gb link) deliver=
s
> >  packets at about 1.300.000 pps to 16 cpus (one cpu per queue) and =
these
> > packets are then redistributed by RPS to same 16 cpus, generating a=
bout
> > 650.000 IPI per second.
>=20
> BTW if rps was SMT aware it could avoid a lot of the IPIs in the firs=
t place.

RPS do what you want, just stick a good cpumask, not a unware one :)

In my test, I specifically do something 'stupid' like :

echo fffe >/sys/class/net/bond0.2240/queues/rx-0/rps_cpus
echo fffd >/sys/class/net/bond0.2240/queues/rx-1/rps_cpus
echo fffb >/sys/class/net/bond0.2240/queues/rx-2/rps_cpus
echo fff7 >/sys/class/net/bond0.2240/queues/rx-3/rps_cpus

echo ffef >/sys/class/net/bond0.2240/queues/rx-4/rps_cpus
echo ffdf >/sys/class/net/bond0.2240/queues/rx-5/rps_cpus
echo ffbf >/sys/class/net/bond0.2240/queues/rx-6/rps_cpus
echo ff7f >/sys/class/net/bond0.2240/queues/rx-7/rps_cpus

echo feff >/sys/class/net/bond0.2240/queues/rx-8/rps_cpus
echo fdff >/sys/class/net/bond0.2240/queues/rx-9/rps_cpus
echo fbff >/sys/class/net/bond0.2240/queues/rx-10/rps_cpus
echo f7ff >/sys/class/net/bond0.2240/queues/rx-11/rps_cpus

echo efff >/sys/class/net/bond0.2240/queues/rx-12/rps_cpus
echo dfff >/sys/class/net/bond0.2240/queues/rx-13/rps_cpus
echo bfff >/sys/class/net/bond0.2240/queues/rx-14/rps_cpus
echo 7fff >/sys/class/net/bond0.2240/queues/rx-15/rps_cpus

echo 0001 >/proc/irq/*/eth1-fp-0/../smp_affinity
echo 0002 >/proc/irq/*/eth1-fp-1/../smp_affinity
echo 0004 >/proc/irq/*/eth1-fp-2/../smp_affinity
echo 0008 >/proc/irq/*/eth1-fp-3/../smp_affinity
echo 0010 >/proc/irq/*/eth1-fp-4/../smp_affinity
echo 0020 >/proc/irq/*/eth1-fp-5/../smp_affinity
echo 0040 >/proc/irq/*/eth1-fp-6/../smp_affinity
echo 0080 >/proc/irq/*/eth1-fp-7/../smp_affinity
echo 0100 >/proc/irq/*/eth1-fp-8/../smp_affinity
echo 0200 >/proc/irq/*/eth1-fp-9/../smp_affinity
echo 0400 >/proc/irq/*/eth1-fp-10/../smp_affinity
echo 0800 >/proc/irq/*/eth1-fp-11/../smp_affinity
echo 1000 >/proc/irq/*/eth1-fp-12/../smp_affinity
echo 2000 >/proc/irq/*/eth1-fp-13/../smp_affinity
echo 4000 >/proc/irq/*/eth1-fp-14/../smp_affinity
echo 8000 >/proc/irq/*/eth1-fp-15/../smp_affinity


You mean we can wakeup a thread with something else than an IPI ?



