From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] bonding: Fix RTNL: assertion failed at
 net/core/rtnetlink.c for ab arp monitor
Date: Tue, 25 Feb 2014 17:34:01 -0500 (EST)
Message-ID: <20140225.173401.1376027261153019177.davem@davemloft.net>
References: <1392800711-19264-1-git-send-email-dingtianhong@huawei.com>
	<1392800711-19264-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	cwang@twopensource.com, jiri@resnulli.us, thomas@glanzmann.de,
	eric.dumazet@gmail.com, sfeldma@cumulusnetworks.com,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbaBYWeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 17:34:04 -0500
In-Reply-To: <1392800711-19264-3-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 19 Feb 2014 17:05:11 +0800

> -static bool bond_ab_arp_probe(struct bonding *bond)
> +static int bond_ab_arp_probe(struct bonding *bond)
>  {
>  	struct slave *slave, *before = NULL, *new_slave = NULL,
> -		     *curr_arp_slave, *curr_active_slave;
> +		     *curr_arp_slave = rcu_dereference(bond->current_arp_slave),
> +		     *curr_active_slave = rcu_dereference(bond->curr_active_slave);
>  	struct list_head *iter;
>  	bool found = false;
> -
> -	rcu_read_lock();
> -	curr_arp_slave = rcu_dereference(bond->current_arp_slave);
> -	curr_active_slave = rcu_dereference(bond->curr_active_slave);
> +	int slave_should_notify = 0;

Likewise use bool here and then you don't have to change the return type
of this function.
