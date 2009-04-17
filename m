From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Fri, 17 Apr 2009 01:07:10 -0700 (PDT)
Message-ID: <20090417.010710.59150850.davem@davemloft.net>
References: <20090416215033.3e648a7a@nehalam>
	<49E810B0.9000906@cosmosbay.com>
	<20090417054032.GD6885@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, shemminger@vyatta.com, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: paulmck@linux.vnet.ibm.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090417054032.GD6885@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 16 Apr 2009 22:40:32 -0700

> I completely agree that this RCU is absolutely -not- 2.6.30 material.  ;-)

I don't understand why we're writing such complicated code.

Oh I see why, it's because not every arch uses the generic SMP helpers
yet :-)

Because if they did universally, we could solve this problem so
simply, by merely sending a remote softirq to every online cpu.  Once
those all complete we have enough of a quiesce period, every cpu must
have exited any netfilter packet processing code path they were in.

And we could know they complete using an atomic counter or something.
