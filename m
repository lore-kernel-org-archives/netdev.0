From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Tue, 10 Jul 2012 11:15:07 +0200
Message-ID: <1341911707.3265.4603.camel@edumazet-glaptop>
References: <1341837625.3265.2748.camel@edumazet-glaptop>
	 <1341887508-20302-1-git-send-email-gaofeng@cn.fujitsu.com>
	 <1341893650.3265.3974.camel@edumazet-glaptop>
	 <4FFBED84.1030905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizefan@huawei.com, tj@kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFBED84.1030905@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-10 at 16:53 +0800, Gao feng wrote:
> > Hi Gao
> > 
> > Is it still needed to call update_netdev_tables() from write_priomap() ?
> > 
> 
> Yes, I think it's needed,because read_priomap will show all of the net devices,
> 
> But we may add the netdev after create a netprio cgroup, so the new added netdev's
> priomap will not be allocated. if we don't call update_netdev_tables in write_priomap,
> we may access this unallocated memory.
> 

I realize my question was not clear.

If we write in write_priomap() a field of a single netdevice,
why should we allocate memory for all netdevices on the machine ?

So the question was : Do we really need to call
update_netdev_tables(alldevs), instead of extend_netdev_table(dev)
