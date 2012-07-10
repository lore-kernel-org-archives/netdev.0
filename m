From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Tue, 10 Jul 2012 13:05:50 +0200
Message-ID: <1341918350.3265.4830.camel@edumazet-glaptop>
References: <1341917043-13264-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, lizefan@huawei.com, tj@kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341917043-13264-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-10 at 18:44 +0800, Gao feng wrote:
> there are some out of bound accesses in netprio cgroup.

> -	update_netdev_tables();
> +	ret = extend_netdev_table(dev, max_len);
> +	if (ret < 0)
> +		goto out_free_devname;
> +
>  	ret = 0;
>  	rcu_read_lock();
>  	map = rcu_dereference(dev->priomap);

Its unfortunately adding a bug.

extend_netdev_table() is protected by RTNL.
