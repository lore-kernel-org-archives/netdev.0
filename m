From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Tue, 17 Mar 2009 22:19:58 +0100
Message-ID: <49C013FE.90004@cosmosbay.com>
References: <OF37E3EF60.503CB684-ON8825757C.006B831D-8825757C.006C0301@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brian Bloniarz <bmb@athenacr.com>, cl@linux-foundation.org,
	David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56546 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbZCQVVd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:21:33 -0400
In-Reply-To: <OF37E3EF60.503CB684-ON8825757C.006B831D-8825757C.006C0301@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens a =E9crit :
> I did some testing with this and see at least a 20% improvement
> without drop.
>=20
> I agree with Peter's recommended changes (esp. sentinel vs null),
> and also the trivial brace indentation  in softirq_delay_exec(),
> but otherwise looks  good to me. Nice work.
>=20
>                                         +-DLS
>=20
>=20

Still I dont like very much all softirq.c changes. I feel very
uncomfortable to justify one extra call in do_softirq(), and
not very clean interface (stuff about locking, barriers...)

Easy way could be to add a SOFTIRQ but its not very wise.

I was wondering if we could use the infrastructure added in commit
54514a70adefe356afe854e2d3912d46668068e6
(softirq: Add support for triggering softirq work on softirqs.)
But I dont understand how it can works...
(softirq_work_list is feeded, but never processed)

Alternatively, we could use a framework dedicated to
network use, with well defined semantic :

Calling softirq_delay_exec() from net_rx_action(),
from this function, we know if time_squeeze was incremented,
or all netdev_budget consumed, and in this stress case=20
try to give the wakeups job to another cpu.



