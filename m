From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] netfilter: per-cpu spin-lock with recursion (v0.8)
Date: Fri, 17 Apr 2009 19:08:15 +0200
Message-ID: <1239988095.23397.4823.camel@laptop>
References: <20090415170111.6e1ca264@nehalam>
	 <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
	 <49E72E83.50702@trash.net>	<20090416.153354.170676392.davem@davemloft.net>
	 <20090416234955.GL6924@linux.vnet.ibm.com>
	 <20090416165233.5d8bbfb5@nehalam> <49E81B9D.3030807@cosmosbay.com>
	 <49E81E63.2090909@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	kaber@trash.net, torvalds@linux-foundation.org,
	jeff.chua.linux@gmail.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E81E63.2090909@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-04-17 at 08:14 +0200, Eric Dumazet wrote:
> > Also, please dont call this a 'recursive lock', since it is not a general
> > recursive lock, as pointed by Linus and Paul.
> > 
> > Second question is about MAX_LOCK_DEPTH
> 
> I meant here the ~256 limit we have on preempt_count, not related to LOCKDEP

Very good point, so 256 nested spin_lock() instances will make the
kernel unhappy -- since we now (almost?) support up to 4096 cpus, this
seems like a no-no.

