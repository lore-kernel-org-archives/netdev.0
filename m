From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: disallow enslaving a bond to itself
Date: Thu, 27 Feb 2014 09:30:56 +0800
Message-ID: <530E9550.6030906@huawei.com>
References: <20140226172013.GA18145@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jiri Bohac <jbohac@suse.cz>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:39962 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbaB0BbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 20:31:08 -0500
In-Reply-To: <20140226172013.GA18145@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/27 1:20, Jiri Bohac wrote:
> Enslaving a bond to itself leads to an endless loop and hangs the kernel.
> 

Yes, I met the same problem.

Tested-by: Ding Tianhong <dingtianhong@huawei.com>

> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 1c6104d..8f028ac 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1193,6 +1193,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		return -EBUSY;
>  	}
>  
> +	if (bond_dev == slave_dev) {
> +		pr_err("%s: cannot enslave bond to itself.\n", bond_dev->name);
> +		return -EPERM;
> +	}
> +
>  	/* vlan challenged mutual exclusion */
>  	/* no need to lock since we're protected by rtnl_lock */
>  	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
> 
