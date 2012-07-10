From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: cgroup: fix access the unallocated memory in netprio
 cgroup
Date: Tue, 10 Jul 2012 16:53:24 +0800
Message-ID: <4FFBED84.1030905@cn.fujitsu.com>
References: <1341837625.3265.2748.camel@edumazet-glaptop>  <1341887508-20302-1-git-send-email-gaofeng@cn.fujitsu.com> <1341893650.3265.3974.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizefan@huawei.com, tj@kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341893650.3265.3974.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Hi Gao
> 
> Is it still needed to call update_netdev_tables() from write_priomap() ?
> 

Yes, I think it's needed,because read_priomap will show all of the net devices,

But we may add the netdev after create a netprio cgroup, so the new added netdev's
priomap will not be allocated. if we don't call update_netdev_tables in write_priomap,
we may access this unallocated memory.
