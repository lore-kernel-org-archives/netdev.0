From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Tue, 14 Apr 2009 20:23:59 -0700 (PDT)
Message-ID: <20090414.202359.07968871.davem@davemloft.net>
References: <20090414111716.28585806@nehalam>
	<49E4E3E8.5090201@cosmosbay.com>
	<20090414141351.0f63ac98@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jeff.chua.linux@gmail.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, paulus@samba.org, mingo@elte.hu,
	torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: shemminger@vyatta.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090414141351.0f63ac98@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 14 Apr 2009 14:13:51 -0700

> This is an alternative version of ip/ip6/arp tables locking using
> per-cpu locks.  This avoids the overhead of synchronize_net() during
> update but still removes the expensive rwlock in earlier versions.
> 
> The idea for this came from an earlier version done by Eric Dumazet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  The slow case involves acquiring the locks on
> all cpu's.
> 
> The mutex that was added for 2.6.30 in xt_table is unnecessary since
> there already is a mutex for xt[af].mutex that is held.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Things seem to be winding down, good. :-)

I'll let Patrick McHardy merge this to me with his other pending
netfilter fixes.

Thanks!
