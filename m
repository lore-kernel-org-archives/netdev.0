From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Tue, 22 May 2012 15:15:54 -0400 (EDT)
Message-ID: <20120522.151554.106838106733194160.davem@davemloft.net>
References: <4FBB6105.2060808@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yanmin_zhang@linux.intel.com
To: kunx.jiang@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FBB6105.2060808@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "kun.jiang" <kunx.jiang@intel.com>
Date: Tue, 22 May 2012 17:48:53 +0800

> From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
> 
> We hit a kernel OOPS.
 ...
> In function free_fib_info, we don't reset nexthop_nh->nh_dev to NULL before releasing
> nh_dev. kfree_rcu(fi, rcu) would release the whole area.
> 
> Signed-off-by: Yanmin Zhang <yanmin_zhang@linux.intel.com>
> Signed-off-by: Kun Jiang <kunx.jiang@intel.com>

This isn't a fix.  You're keeping around a pointer to a completely
released object, which is therefore illegal to dereference.

That's why we must set it to NULL, to catch such illegal accesses.
