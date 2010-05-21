From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Fri, 21 May 2010 10:38:48 -0700
Message-ID: <20100521103848.12f07c23@nehalam>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	<1269377667.2915.25.camel@edumazet-laptop>
	<20100323.144512.140757007.davem@davemloft.net>
	<1269382380.2915.40.camel@edumazet-laptop>
	<20100521084349.0d6f8f9a@nehalam>
	<1274460275.2439.469.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40566 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706Ab0EURiz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 13:38:55 -0400
In-Reply-To: <1274460275.2439.469.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 May 2010 18:44:35 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 21 mai 2010 =E0 08:43 -0700, Stephen Hemminger a =E9crit =
:
>=20
> > What about having a special function (spin_lock_greedy?) that just =
ignores
> > the ticket mechanism and always assumes it has right to next ticket=
=2E
> >=20
>=20
> I am not sure we want to do this, for a single use case...
> Adding a new lock primitive to linux should be really really motivate=
d.
>=20
> x86 ticket spinlocks are nice because we are sure no cpu is going to
> stay forever in this code. For other arches, I dont know how this is
> coped.
>=20
> I thought about this before re-working on this patch, but found it wa=
s
> easier to slightly change Alexander code, ie adding a regular spinloc=
k
> for the slowpath.
>=20
> We could use cmpxchg() and manipulate several bits at once in fast pa=
th.
> ( __QDISC_STATE_RUNNING, __QDISC_STATE_LOCKED ... ) but making the cr=
owd
> of cpus spin on the same bits/cacheline than dequeue worker would
> definitely slowdown the worker.

Your solution is okay, but it is a special case performance hack
and we seem to be getting more and more of these lately.
This is a general problem of any producer/consumer case;
other code will have same problem (like disk requests)=20
and can't use the same solution.

Maybe the RT and scheduler folks have some input because it does
seem like the same problem has occurred in other contexts before.

--=20
