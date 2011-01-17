From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Mon, 17 Jan 2011 10:16:35 +0100
Message-ID: <20110117091635.GA8751@nuttenaction>
References: <1295021808.3937.110.camel@edumazet-laptop>
 <20110114095201.4fc58a45@nehalam>
 <1295028502.3937.116.camel@edumazet-laptop>
 <20110114110342.4d95ad5b@nehalam>
 <20110116223540.GA1861@del.dom.local>
 <AANLkTim14h+6k6nt+UWP5gDcT5NmAGLU_S+wG6VhDn-O@mail.gmail.com>
 <1295248669.12859.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:56737 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752777Ab1AQJQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 04:16:38 -0500
Content-Disposition: inline
In-Reply-To: <1295248669.12859.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-01-17 08:17:49 [+0100]:

>Hmm, considering qdisc stats are not used in kernel (only updated and
>reported to tc users) it seems to me counting arrival instead of
>departure rates is mostly useless for the user, if drops are ignored.
>
>(I am not speaking of direct drops, when we try to enqueue() this skb,
>but later ones, when another skb is enqueued and we drop a previously
>enqueued skb)
>
>User really wants to see the effective departure rate, to check its
>qdisc parameters in respect with kernel ones (HZ=100/1000, HIGH res
>timers off/on, ...)
>
>Arrival rates are of litle use. However, it might be good to have a
>second "bstats" only for dropped packets/bytes, or extend bstats in a
>compatible way (maybe adding fields to the end of structure)

Sure, qdiscs like CHOKe, SFQ, pfifo_head are only analyzable with this kind of
additional information. E.g. pfifo_head currently provides no statistic that
the queue length is possible underestimated and tunning is required.

Hagen
