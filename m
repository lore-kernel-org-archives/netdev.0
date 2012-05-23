From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Tue, 22 May 2012 23:23:10 -0400 (EDT)
Message-ID: <20120522.232310.911242148705021745.davem@davemloft.net>
References: <4FBB6105.2060808@intel.com>
	<20120522.151554.106838106733194160.davem@davemloft.net>
	<1337742123.14538.175.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kunx.jiang@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yanmin_zhang@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337742123.14538.175.camel@ymzhang.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Date: Wed, 23 May 2012 11:02:03 +0800

> 1) Why does free_fib_info call call_rcu instead of releasing fi directly?
> I assume other cpu might be accessing it. nexthop_nh->nh_dev is in fi.
> If other cpu are accessing it, here resetting to NULL would cause other
> cpu panic.

Because fib trie lookups are done with RCU locking, therefore we must
use RCU freeing to release the object.

What I was trying to impart to you is that removing the NULL
assignment is wrong and that an alternative fix is warranted (hint:
consider moving something into the RCU release).
