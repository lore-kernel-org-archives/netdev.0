From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 14:10:16 +0100
Message-ID: <4AFD5AB8.2070902@gmail.com>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>	 <20091113074508.GA6605@ff.dom.local>	 <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>	 <20091113091825.GA7449@ff.dom.local>	 <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>	 <20091113095731.GA7749@ff.dom.local> <412e6f7f0911130325r20e2fbbbg21e2e384de1f7c0f@mail.gmail.com>
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
Received: from gw1.cosmosbay.com ([212.99.114.194]:36307 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbZKMNKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 08:10:18 -0500
In-Reply-To: <412e6f7f0911130325r20e2fbbbg21e2e384de1f7c0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =C3=A9crit :
> On Fri, Nov 13, 2009 at 5:57 PM, Jarek Poplawski <jarkao2@gmail.com> =
wrote:
>> I'm not against your solution at all. It only needs more proof...
>=20
> I know. :)
>=20
>> You seem to forget the main networking paths now are just softirq, a=
nd
>> it's probably for some reason. If kernel threads are good enough, it
>> seems we should do more such changes.
>>
>=20
> I find there is still a softirqd kernel thread for each online CPU,
> and these threads will be waked up if there are more SoftIRQs need to
> be done after restarting the SoftIRQ processing many times, to keep
> the whole system responsible. Did I miss sth.? And at the other side,
> real time branch just wants to make all the activities based on kerne=
l
> threads, even ISR.
>=20
>=20


You seem to focus on stress loads, where we enter ksoftirqd more to get
more throughput (and cpu fairness), at latency expense.

But in normal situations, ksoftirq is not started at all.

