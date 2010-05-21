From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Fri, 21 May 2010 19:40:43 +0200
Message-ID: <1274463643.2439.473.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	 <1269377667.2915.25.camel@edumazet-laptop>
	 <20100323.144512.140757007.davem@davemloft.net>
	 <1269382380.2915.40.camel@edumazet-laptop>
	 <20100521084349.0d6f8f9a@nehalam>
	 <1274460275.2439.469.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:58591 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758141Ab0EURkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 13:40:47 -0400
Received: by wwi18 with SMTP id 18so883116wwi.19
        for <netdev@vger.kernel.org>; Fri, 21 May 2010 10:40:46 -0700 (PDT)
In-Reply-To: <1274460275.2439.469.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 mai 2010 =C3=A0 18:44 +0200, Eric Dumazet a =C3=A9crit :

> We could use cmpxchg() and manipulate several bits at once in fast pa=
th.
> ( __QDISC_STATE_RUNNING, __QDISC_STATE_LOCKED ... ) but making the cr=
owd
> of cpus spin on the same bits/cacheline than dequeue worker would
> definitely slowdown the worker.
>=20
>=20

Maybe I am missing something, but __QDISC_STATE_RUNNING is always
manipulated with the lock held...

We might avoid two atomic ops when changing this state (if moved to a
separate container) in fast path (when a cpu sends only one packet and
returns)



