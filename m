From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v4] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Thu, 12 Jul 2012 06:56:11 -0400
Message-ID: <20120712105611.GA7055@hmsreliant.think-freely.org>
References: <1342079415-9631-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342079415-9631-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2012 at 03:50:15PM +0800, Gao feng wrote:
> there are some out of bound accesses in netprio cgroup.
> 
> now before accessing the dev->priomap.priomap array,we only check
> if the dev->priomap exist.and because we don't want to see
> additional bound checkings in fast path, so we should make sure
> that dev->priomap is null or array size of dev->priomap.priomap
> is equal to max_prioidx + 1;
> 
> so in write_priomap logic,we should call extend_netdev_table when
> dev->priomap is null and dev->priomap.priomap_len < max_len.
> and in cgrp_create->update_netdev_tables logic,we should call
> extend_netdev_table only when dev->priomap exist and
> dev->priomap.priomap_len < max_len.
> 
> and it's not needed to call update_netdev_tables in write_priomap,
> we can only allocate the net device's priomap which we change through
> net_prio.ifpriomap.
> 
> this patch also add a return value for update_netdev_tables &
> extend_netdev_table, so when new_priomap is allocated failed,
> write_priomap will stop to access the priomap,and return -ENOMEM
> back to the userspace to tell the user what happend.
> 
> Change From v3:
> 1. add rtnl protect when reading max_prioidx in write_priomap.
> 
> 2. only call extend_netdev_table when map->priomap_len < max_len,
>    this will make sure array size of dev->map->priomap always
>    bigger than any prioidx.
> 
> 3. add a function write_update_netdev_table to make codes clear.
> 
> Change From v2:
> 1. protect extend_netdev_table by RTNL.
> 2. when extend_netdev_table failed,call dev_put to reduce device's refcount.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Eric Dumazet <edumazet@google.com>

Thank you Gao.
Acked-by: Neil Horman <nhorman@tuxdriver.com>
