From: David Miller <davem@davemloft.net>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Thu, 18 Nov 2010 09:48:37 -0800 (PST)
Message-ID: <20101118.094837.260089185.davem@davemloft.net>
References: <1289312742.18992.21.camel@edumazet-laptop>
	<1290088353.2781.137.camel@edumazet-laptop>
	<1290102113.2781.237.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jdb@comx.dk, netdev@vger.kernel.org, lawrence@brakmo.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55697
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755048Ab0KRRsS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 12:48:18 -0500
In-Reply-To: <1290102113.2781.237.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Nov 2010 18:41:53 +0100

> Le jeudi 18 novembre 2010 =E0 14:52 +0100, Eric Dumazet a =E9crit :
>> Le mardi 09 novembre 2010 =E0 15:25 +0100, Eric Dumazet a =E9crit :
>>=20
>> My tests show a problem with backlog processing, and too big TCP
>> windows. (at least on loopback and wild senders)
>>=20
>> Basically, with huge tcp windows we have now (default 4 Mbytes),
>> the reader process can have to process up to 4Mbytes of backlogged d=
ata
>> in __release_sock() before returning from its 'small' read(fd, buffe=
r,
>> 1024) done by netcat.
>>=20
>> While it processes this backlog, it sends tcp ACKS, allowing sender =
to
>> send new frames that might be dropped because of sk_rcvqueues_full()=
, or
>> continue to fill receive queue up to the receiver window, feeding th=
e
>> task in __release_sock() [loop]
>>=20
>>=20
>> This blows cpu caches completely [data is queued, and the dequeue is
>> done long after], and latency of a single read() can be very high. T=
his
>> blocks the pipeline of user processing eventually.

Thanks for looking into this Eric.

We definitely need some kind of choke point so that TCP never
significantly exceeds the congestion window point at which throughput
stops increasing (and only latency does).

One idea is that when we integrate Lawrence Brakmo's TCP-NV congestion
control algorithm, we can try enabling it by default over loopback.

Loopback is kind of an interesting case of the problem scenerio
Lawrence is trying to solve.

