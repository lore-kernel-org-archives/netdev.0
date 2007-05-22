From: John Miller <forall@mail15.com>
Subject: Re: UDP packet loss when running lsof
Date: Wed, 23 May 2007 02:42:47 +0400
Message-ID: <20070523024247.34nh5ck1j4ooc0o8@www.pochta.ru>
References: <loom.20070521T090409-252@post.gmane.org>
	<20070521113503.6bb70ae4.dada1@cosmosbay.com>
	<20070522021259.95ukifwz8kc4gccg@www.pochta.ru>
	<46528973.50809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=Windows-1251;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web6.pochta.ru ([81.211.64.26]:40430 "EHLO web6.pochta.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758018AbXEVWmu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 18:42:50 -0400
In-Reply-To: <46528973.50809@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Eric,

> > It's a HP system with two dual core CPUs at 3GHz, the

> Then you might try to bind network IRQ to one CPU
> (echo 1 >/proc/irq/XX/smp_affinity)

> XX being your NIC interrupt (cat /proc/interrupts to catch it)

> and bind your user program to another cpu(s)

the NIC was already fixed at CPU0 and the irq_balancer switched
the timer interrupt between all CPUs and the storage HBA between
CPU1 and CPU4. Stopping the balancer and leaving NIC alone on CPU0
and the other interrupts and my program on CPU2-4 did not improve
the situation.
At least I could not see an improvement over just adding
thash_entries=2048.

> You might hit a cond_resched_softirq() bug that Ingo and others
> are sorting out right now. Using separate CPU for softirq
> handling and your programs should help a lot here.

Shouldn't I get some syslog messages if this bug is triggered?

Nevertheless I also opened a call on Novell about this issue,
as the current cond_resched_softirq() does look completely
different than in 2.6.18

> > This did help a lot, I tried thash_entries=10 and now only a
> > while loop around the "cat ...tcp" triggers packet loss. Tests

> I dont understand here : using a small thash_entries makes
> the bug always appear ?

No. thash_entries=10 improves the situation. Without the param
nearly every look at /proc/net/tcp leads to packet loss, with
thash_entries=10 (or 2048, does not matter) I have to start a
"while true; do cat /prc/net/tcp ; done" to get packet loss
every minute.

But even with thash_entries=10 and if I leave my program alone
  on he system I get packet loss every few hours.

Regards,
John




