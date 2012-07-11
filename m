From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Wed, 11 Jul 2012 08:11:02 -0400
Message-ID: <20120711121102.GB26643@hmsreliant.think-freely.org>
References: <1341995406-12719-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, lizefan@huawei.com, tj@kernel.org,
	davem@davemloft.net, Eric Dumazet <edumazet@google.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341995406-12719-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 11, 2012 at 04:30:06PM +0800, Gao feng wrote:
> there are some out of bound accesses in netprio cgroup.
> 
> now before accessing the dev->priomap.priomap array,we only check
> if the dev->priomap exist.and because we don't want to see
> additional bound checkings in fast path, so we should make sure
> that dev->priomap is null or array size of dev->priomap.priomap
> is equal to max_prioidx + 1;
> 
> and it's not needed to call extend_netdev_tabel in write_priomap,
> we can only allocate the net device's priomap which we change through
> net_prio.ifpriomap.
> 
> this patch add a return value for update_netdev_tables & extend_netdev_table,
> so when new_priomap is allocated failed,write_priomap will stop to access
> the priomap,and return -ENOMEM back to the userspace to tell the user
> what happend.
> 
> Change From v2:
> 1. protect extend_netdev_table by RTNL.
> 2. when extend_netdev_table failed,call dev_put to reduce device's refcount.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/netprio_cgroup.c |   54 ++++++++++++++++++++++++++++++++------------
>  1 files changed, 39 insertions(+), 15 deletions(-)
> 
I still think the use of max_priomap in write_priomap is racy (please see my
previous note).

Neil
