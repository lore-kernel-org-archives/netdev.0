From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 20:04:02 +0200
Message-ID: <1271268242.16881.1719.camel@edumazet-laptop>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:57338 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756194Ab0DNSEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 14:04:10 -0400
Received: by bwz25 with SMTP id 25so512610bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 11:04:08 -0700 (PDT)
In-Reply-To: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 10:31 -0700, Tom Herbert a =C3=A9crit =
:
> The point of RPS is to increase parallelism, but the cost of that is
> more overhead per packet.  If you are running a single flow, then
> you'll see latency increase for that flow.  With more concurrent flow=
s
> the benefits of parallelism kick in and latency gets better.-- we've
> seen the break even point around ten connections in our tests.  Also,
> I don't think we've made the claim that RPS should generally perform
> better than multi-queue, the primary motivation for RPS is make singl=
e
> queue NICs give reasonable performance.
>=20

Yes, multiqueue is far better of course, but in case of hardware lackin=
g
multiqueue, RPS can help many workloads, where application has _some_
work to do, not only counting frames or so...

RPS overhead (IPI, cache misses, ...) must be amortized by
parallelization or we lose.

A ping test is not an ideal candidate for RPS, since everything is done
at softirq level, and should be faster without RPS...



