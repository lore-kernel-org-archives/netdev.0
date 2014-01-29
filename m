From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: fix locking in
 bond_loadbalance_arp_mon()
Date: Tue, 28 Jan 2014 23:48:58 -0800 (PST)
Message-ID: <20140128.234858.302883010176792367.davem@davemloft.net>
References: <52E728A5.5070701@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbaA2Hs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 02:48:58 -0500
In-Reply-To: <52E728A5.5070701@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 28 Jan 2014 11:48:53 +0800

> The commit 1d3ee88ae0d605629bf369
> (bonding: add netlink attributes to slave link dev)
> has add rtmsg_ifinfo() in bond_set_active_slave() and
> bond_set_backup_slave(), so the two function need to
> called in RTNL lock, but bond_loadbalance_arp_mon()
> only calling these functions in RCU, warning message
> will occurs.
> 
> fix this by add a new function bond_slave_state_change(),
> which will reset the slave's state after slave link check,
> so remove the bond_set_xxx_slave() from the cycle and only
> record the slave_state_changed, this will call the new
> function to set all slaves to new state in RTNL later.
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks.
