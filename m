From: Moni Shoua <monis@voltaire.com>
Subject: Re: [PATCH linux-2.6] bonding: two small fixes for IPoIB support
Date: Tue, 16 Oct 2007 09:56:54 +0200
Message-ID: <47146EC6.1000109@voltaire.com>
References: <47138EB7.40703@gmail.com> <4713B006.9090908@pobox.com> <27349.1192480486@death> <4713D28F.3010904@pobox.com> <31162.1192485233@death> <4713E20F.9080305@pobox.com> <9245.1192491867@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org, Or Gerlitz <ogerlitz@voltaire.com>,
	Moni Levy <monil@voltaire.com>
To: Jay Vosburgh <fubar@us.ibm.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:37206 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765205AbXJPH45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 03:56:57 -0400
In-Reply-To: <9245.1192491867@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Two small fixes to IPoIB support for bonding:
> 
> 	1- copy header_ops from slave to bonding for IPoIB slaves
> 	2- move release and destroy logic to UNREGISTER from GOING_DOWN
> 	   notifier to avoid double release
> 
> 	Set bonding to version 3.2.1.
> 
> Signed-off-by: Moni Shoua <monis at voltaire.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 
> ---
>  drivers/net/bonding/bond_main.c |   11 +++++------
>  drivers/net/bonding/bonding.h   |    4 ++--
>  2 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index db80f24..6f85cc3 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1263,6 +1263,7 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
>  	struct bonding *bond = bond_dev->priv;
>  
>  	bond_dev->neigh_setup           = slave_dev->neigh_setup;
> +	bond_dev->header_ops		= slave_dev->header_ops;
>  
>  	bond_dev->type		    = slave_dev->type;
>  	bond_dev->hard_header_len   = slave_dev->hard_header_len;
> @@ -3351,7 +3352,10 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
>  	switch (event) {
>  	case NETDEV_UNREGISTER:
>  		if (bond_dev) {
> -			bond_release(bond_dev, slave_dev);
> +			if (bond->setup_by_slave)
> +				bond_release_and_destroy(bond_dev, slave_dev);
> +			else
> +				bond_release(bond_dev, slave_dev);
>  		}
>  		break;
>  	case NETDEV_CHANGE:
> @@ -3366,11 +3370,6 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
>  		 * ... Or is it this?
>  		 */
>  		break;
> -	case NETDEV_GOING_DOWN:
> -		dprintk("slave %s is going down\n", slave_dev->name);
> -		if (bond->setup_by_slave)
> -			bond_release_and_destroy(bond_dev, slave_dev);
> -		break;
>  	case NETDEV_CHANGEMTU:
>  		/*
>  		 * TODO: Should slaves be allowed to
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index a8bbd56..b818060 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -22,8 +22,8 @@
>  #include "bond_3ad.h"
>  #include "bond_alb.h"
>  
> -#define DRV_VERSION	"3.2.0"
> -#define DRV_RELDATE	"September 13, 2007"
> +#define DRV_VERSION	"3.2.1"
> +#define DRV_RELDATE	"October 15, 2007"
>  #define DRV_NAME	"bonding"
>  #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
>  
Jay,
Thanks for this work.

Jeff,
Thanks for applying.
I noticed that this patch isn't applied. It includes important fixes. 
Can you please apply it also?


	MoniS


