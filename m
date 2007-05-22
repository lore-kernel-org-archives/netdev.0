From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: UDP packet loss when running lsof
Date: Tue, 22 May 2007 08:47:40 +0200
Message-ID: <4652920C.8020608@cosmosbay.com>
References: <loom.20070521T090409-252@post.gmane.org>	<20070521113503.6bb70ae4.dada1@cosmosbay.com> <20070522021259.95ukifwz8kc4gccg@www.pochta.ru> <46528973.50809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Miller <forall@mail15.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43527 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757628AbXEVGrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 02:47:49 -0400
In-Reply-To: <46528973.50809@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =C3=A9crit :
> John Miller a =C3=A9crit :
>> Hi Eric,
>>
>>> I CCed netdev since this stuff is about network and not
>>> lkml.
>>
>> Ok, dropped the CC...
>>
>>> What kind of machine do you have ? SMP or not ?
>>
>> It's a HP system with two dual core CPUs at 3GHz, the
>> storage system is connected through QLogic FC-HBA. It should
>> really be fast enough to handle a data stream of 50 MB/s...
>=20
> Then you might try to bind network IRQ to one CPU
> (echo 1 >/proc/irq/XX/smp_affinity)
>=20
> XX being your NIC interrupt (cat /proc/interrupts to catch it)
>=20
> and bind your user program to another cpu(s)
>=20
> You might hit a cond_resched_softirq() bug that Ingo and others are=20
> sorting out right now. Using separate CPU for softirq handling and yo=
ur=20
> programs should help a lot here.

You might try this patch, now that Ingo "Signed-off-by" it.

http://marc.info/?l=3Dlinux-kernel&m=3D117981607429875&w=3D2


I guess that with a correct softirq resched, no need to play with IRQ=20
affinities, unless you really want to push performance.

