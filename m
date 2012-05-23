From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 12:54:57 +0800
Message-ID: <1337748897.14538.184.camel@ymzhang.sh.intel.com>
References: <4FBB6105.2060808@intel.com>
	 <20120522.151554.106838106733194160.davem@davemloft.net>
	 <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	 <20120522.232310.911242148705021745.davem@davemloft.net>
	 <1337747829.3361.1599.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kunx.jiang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337747829.3361.1599.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-23 at 06:37 +0200, Eric Dumazet wrote:
> On Tue, 2012-05-22 at 23:23 -0400, David Miller wrote:
> > From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
> > Date: Wed, 23 May 2012 11:02:03 +0800
> > 
> > > 1) Why does free_fib_info call call_rcu instead of releasing fi directly?
> > > I assume other cpu might be accessing it. nexthop_nh->nh_dev is in fi.
> > > If other cpu are accessing it, here resetting to NULL would cause other
> > > cpu panic.
> > 
> > Because fib trie lookups are done with RCU locking, therefore we must
> > use RCU freeing to release the object.
> > 
> > What I was trying to impart to you is that removing the NULL
> > assignment is wrong and that an alternative fix is warranted (hint:
> > consider moving something into the RCU release).
> > --
> 
> Its more than that I'm afraid.
> 
> fi->fib_dev (aka fib_nh[0].nh_dev) need full RCU protection.
The new patch posted at https://lkml.org/lkml/2012/5/22/558 does move the
resetting to RCU protection.

> 
> Also the "fib_info_cnt--;" must stay in free_fib_info() (so that it is
> protected by RTNL)
We would move "fib_info_cnt--;" back to free_fib_info.

Thanks,
Yanmin
