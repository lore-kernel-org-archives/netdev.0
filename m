From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH RFC] v2 expedited "big hammer" RCU grace periods
Date: Tue, 28 Apr 2009 00:56:02 +0400
Message-ID: <20090427205601.GA5716@ioremap.net>
References: <20090426052340.GA24931@linux.vnet.ibm.com> <20090426112717.GE10391@elte.hu> <20090426191343.GC29238@Krystal> <20090426202255.GA5365@elte.hu> <20090426214451.GC6945@linux.vnet.ibm.com> <20090427032639.GA10087@elte.hu> <20090427132153.GI6945@linux.vnet.ibm.com> <20090427155424.GA27041@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com,
	jeff.chua.linux@gmail.com, paulus@samba.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, benh@kernel.crashing.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090427155424.GA27041@Krystal>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Mon, Apr 27, 2009 at 11:54:24AM -0400, Mathieu Desnoyers (mathieu.desnoyers@polymtl.ca) wrote:
> It might sound a bit simplistic, but... scheduling a high-priority
> workqueue on every CPUs would give you the guarantees you seem to need
> here. Or is the delay of letting the scheduler schedule a high-priority
> task a delay you are trying to avoid ?

I believe not the abstract (empty) task should be invoked, but a real
task which does the work. Presumably if we want to schedule a way
networking part to copy its counters, system should wake up the
appropriate userspace thread blocked in a grace-period waking path, so
effectively either RCU callback processing code or some registered
thread should be awakened.

Just a detail though.

-- 
	Evgeniy Polyakov
