From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Fri, 21 May 2010 18:44:35 +0200
Message-ID: <1274460275.2439.469.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	 <1269377667.2915.25.camel@edumazet-laptop>
	 <20100323.144512.140757007.davem@davemloft.net>
	 <1269382380.2915.40.camel@edumazet-laptop>
	 <20100521084349.0d6f8f9a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51614 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934009Ab0EUQoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 12:44:39 -0400
Received: by fxm5 with SMTP id 5so1034806fxm.19
        for <netdev@vger.kernel.org>; Fri, 21 May 2010 09:44:38 -0700 (PDT)
In-Reply-To: <20100521084349.0d6f8f9a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 mai 2010 =C3=A0 08:43 -0700, Stephen Hemminger a =C3=A9c=
rit :

> What about having a special function (spin_lock_greedy?) that just ig=
nores
> the ticket mechanism and always assumes it has right to next ticket.
>=20

I am not sure we want to do this, for a single use case...
Adding a new lock primitive to linux should be really really motivated.

x86 ticket spinlocks are nice because we are sure no cpu is going to
stay forever in this code. For other arches, I dont know how this is
coped.

I thought about this before re-working on this patch, but found it was
easier to slightly change Alexander code, ie adding a regular spinlock
for the slowpath.

We could use cmpxchg() and manipulate several bits at once in fast path=
=2E
( __QDISC_STATE_RUNNING, __QDISC_STATE_LOCKED ... ) but making the crow=
d
of cpus spin on the same bits/cacheline than dequeue worker would
definitely slowdown the worker.



