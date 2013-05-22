From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: add synchronize_net() after
 netdev_rx_handler_unregister
Date: Wed, 22 May 2013 04:45:45 -0700
Message-ID: <1369223145.3301.308.camel@edumazet-glaptop>
References: <519C8504.1080906@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:35119 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733Ab3EVLps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:45:48 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so1613081pbb.20
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 04:45:46 -0700 (PDT)
In-Reply-To: <519C8504.1080906@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 16:42 +0800, dingtianhong wrote:
> commit 00cfec3748 (net: add a synchronize_net() ...) add a synchronize_net()
> in netdev_rx_handler_unregister() to guarantee the rx_handler  is NULL when
> rx_handler_data is a non NULL in rcu_read_lock().
> 
> so the caller should not use netdev_rx_handler_unregister in atomic as it may
> schedule and sleep, the commit fcd99434f fix the bug in bond release, but the
> problem is no action to guarantee the rx_handler_data is NULL when bond release,
> so add synchronize_net() and fix it.
> 
> This patch adds more comments to netdev_rx_handler_unregister().
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/bonding/bond_main.c | 2 ++
>  net/core/dev.c                  | 3 +++
>  2 files changed, 5 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index d0aade0..592a603 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2007,6 +2007,8 @@ static int __bond_release_one(struct net_device *bond_dev,
>  	 * for this slave anymore.
>  	 */
>  	netdev_rx_handler_unregister(slave_dev);
> +	synchronize_net();
> +
>  	write_lock_bh(&bond->lock);
>  

Patch is not needed.

This was discussed on netdev, please read the archives.

Its even documented in netdev_rx_handler_unregister(), could you please
read again commit [1]

What about you describe the problems you really noticed ?

[1] commit
00cfec37484761a44a3b6f4675a54caa618210ae
("net: add a synchronize_net() in netdev_rx_handler_unregister()")
