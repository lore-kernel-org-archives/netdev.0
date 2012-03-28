From: David Miller <davem@davemloft.net>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Wed, 28 Mar 2012 17:45:59 -0400 (EDT)
Message-ID: <20120328.174559.650861844028495880.davem@davemloft.net>
References: <alpine.SOC.1.00.1203281134090.13691@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.SOC.1.00.1203281134090.13691@math.ut.ee>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Wed, 28 Mar 2012 11:45:48 +0300 (EEST)

> Is this the same RCU problem that was fixed after 3.3 (fix a potential 
> rcu_read_lock() imbalance in rt6_fill_node())? My problem does not seem 
> to be ipv6-only, most traces are from IPv6 but some for ip.

It's hard to say because the ipv6 RCU problem causes the warning to
trigger somewhere away from the ipv6 code that had the RCU locking
bug.

We essentially return back into userspace with the RCU lock held, so
the next time we go into the kernel for that thread and do RCU locking
is when we'll notice the problem.
