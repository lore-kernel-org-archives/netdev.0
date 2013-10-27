From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bonding: patchset for rcu use in
 bonding
Date: Sun, 27 Oct 2013 16:37:12 -0400 (EDT)
Message-ID: <20131027.163712.1324471504006808112.davem@davemloft.net>
References: <52688F33.30904@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53806 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521Ab3J0UhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 16:37:17 -0400
In-Reply-To: <52688F33.30904@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 24 Oct 2013 11:08:35 +0800

> The slave list will add and del by bond_master_upper_dev_link() and bond_upper_dev_unlink(),
> which will call call_netdevice_notifiers(), even it is safe to call it in write bond lock now,
> but we can't sure that whether it is safe later, because other drivers may deal NETDEV_CHANGEUPPER
> in sleep way, so I didn't admit move the bond_upper_dev_unlink() in write bond lock.
> 
> now the bond_for_each_slave only protect by rtnl_lock(), maybe use bond_for_each_slave_rcu is a good
> way to protect slave list for bond, but as a system slow path, it is no need to transform bond_for_each_slave()
> to bond_for_each_slave_rcu() in slow path, so in the patchset, I will remove the unused read bond lock
> for monitor function, maybe it is a better way, I will wait to accept any relay for it.
> 
> Thanks for the Veaceslav Falico opinion.
> 
> v2: add and modify commit for patchset and patch, it will be the first step for the whole patchset.

Series applied, thanks.
