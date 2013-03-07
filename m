From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: fire NETDEV_RELEASE event only on 0 slaves
Date: Wed, 6 Mar 2013 22:38:19 -0500
Message-ID: <20130307033819.GA3513@neilslaptop.think-freely.org>
References: <1362589832-9526-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43873 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756559Ab3CGDia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 22:38:30 -0500
Content-Disposition: inline
In-Reply-To: <1362589832-9526-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 06, 2013 at 06:10:32PM +0100, Veaceslav Falico wrote:
> Currently, if we set up netconsole over bonding and release a slave,
> netconsole will stop logging on the whole bonding device. Change the
> behavior to stop the netconsole only when the last slave is released.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 7bd068a..8b4e96e 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1964,7 +1964,6 @@ static int __bond_release_one(struct net_device *bond_dev,
>  	}
>  
>  	block_netpoll_tx();
> -	call_netdevice_notifiers(NETDEV_RELEASE, bond_dev);
>  	write_lock_bh(&bond->lock);
>  
>  	slave = bond_get_slave_by_dev(bond, slave_dev);
> @@ -2066,8 +2065,10 @@ static int __bond_release_one(struct net_device *bond_dev,
>  	write_unlock_bh(&bond->lock);
>  	unblock_netpoll_tx();
>  
> -	if (bond->slave_cnt == 0)
> +	if (bond->slave_cnt == 0) {
>  		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
> +		call_netdevice_notifiers(NETDEV_RELEASE, bond->dev);
> +	}
>  
>  	bond_compute_features(bond);
>  	if (!(bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
> -- 
> 1.7.1
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
