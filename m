From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: cgroup: fix out of bounds accesses
Date: Mon, 9 Jul 2012 07:01:54 -0400
Message-ID: <20120709110154.GB9186@hmsreliant.think-freely.org>
References: <1341819910.3265.2106.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, lizefan@huawei.com, tj@kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341819910.3265.2106.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2012 at 09:45:10AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> dev->priomap is allocated by extend_netdev_table() called from
> update_netdev_tables().
> And this is only called if write_priomap() is called.
> 
> But if write_priomap() is not called, it seems we can have out of bounds
> accesses in cgrp_destroy(), read_priomap() & skb_update_prio()
> 
> With help from Gao Feng
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> ---
> net/core/dev.c            |    8 ++++++--
> net/core/netprio_cgroup.c |    4 ++--
> 2 files changed, 8 insertions(+), 4 deletions(-)
> 

Thank you for doing this Eric, Gao.  Just to be sure (I asked in the previous
thread), would it be better to avoid the length check in skb_update_prio, and
instead update the netdev tables to be long enough in cgrp_create and in
netprio_device_event on device registration?

Neil
