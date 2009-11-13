From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 14:55:50 +0100
Message-ID: <4AFD6566.2040007@gmail.com>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>	 <20091113074508.GA6605@ff.dom.local> <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54425 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbZKMNzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 08:55:52 -0500
In-Reply-To: <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =C3=A9crit :

> I have done a simple test. I run a simple program on computer A, whic=
h
> sends SYN packets with random source ports to Computer B's 80 port (N=
o
> socket listens on that port, so tcp reset packets will be sent) in
> 90kpps. On computer B, I redirect the traffic to IFB. At the same
> time, I ping from B to A to get the RTT between them. I can't see any
> difference between the original IFB and my MQ version. They are both:
>=20
> CPU idle: 50%
> Latency: 0.3-0.4ms, burst 2ms.

Yes, but redo your test with normal load (including several user thread=
s
fighting for scheduler/cpu use) :)

softirq preempts user threads instantly (they are interrupts after all =
:) ),
while workqueue do compete with other workqueues/threads.

Tom Herbert RPS solution is still using softirqs.

I like to test workqueue based solution with IFB, but some people might=
 still
keep previous pure softirq solution for production environment, not ben=
chmarks...

