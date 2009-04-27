From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 16:03:52 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904271602390.22156@localhost.localdomain>
References: <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu>
 <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain> <20090427203616.GB3836@ioremap.net> <alpine.LFD.2.00.0904271340400.22156@localhost.localdomain> <20090427144054.1fb9b7a6@nehalam> <alpine.LFD.2.00.0904271506530.22156@localhost.localdomain>
 <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 27 Apr 2009, Linus Torvalds wrote:
> 
> BTW: THIS IS TOTALLY UNTESTED.

Gaah. I should have read through it one more time before sending.

> static inline void xt_info_rdunlock_bh(void)
> {
> 	struct xt_info_lock *lock;
> 
> 	lock = &__get_cpu_var(xt_info_locks);
> 	if (!--lock->readers)
> 		spin_unlock(&lock->lock);
> }

This one was missing the "local_bh_enable()" at the end.

There may be other bugs, but that's the one I noticed immediately when 
reading what I sent out. Oops.

			Linus
