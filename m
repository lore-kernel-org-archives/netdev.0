From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Fri, 22 Aug 2008 16:50:39 -0500
Message-ID: <20080822165039.21b8732d@osprey.hogchain.net>
References: <20080821115849.GA2126@x200.localdomain>
	<20080821210007.5750e285@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:36158 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbYHVV4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 17:56:13 -0400
In-Reply-To: <20080821210007.5750e285@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Aug 2008 21:00:07 -0500
Jay Cliburn <jcliburn@gmail.com> wrote:

> 
> Does this patch fix it?
> 
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index e23ce77..4816c6d 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -1307,7 +1307,6 @@ static u32 atl1_check_link(struct atl1_adapter
> *adapter) if (netif_msg_link(adapter))
>  				dev_info(&adapter->pdev->dev, "link
> is down\n"); adapter->link_speed = SPEED_0;
> -			netif_carrier_off(netdev);
>  		}
>  		return 0;
>  	}
> @@ -1364,8 +1363,6 @@ static u32 atl1_check_link(struct atl1_adapter
> *adapter) /* change original link status */
>  	if (netif_carrier_ok(netdev)) {
>  		adapter->link_speed = SPEED_0;
> -		netif_carrier_off(netdev);
> -		netif_stop_queue(netdev);
>  	}
>  
>  	if (hw->media_type != MEDIA_TYPE_AUTO_SENSOR &&
> @@ -2654,8 +2651,6 @@ static void atl1_down(struct atl1_adapter
> *adapter) 
>  	adapter->link_speed = SPEED_0;
>  	adapter->link_duplex = -1;
> -	netif_carrier_off(netdev);
> -	netif_stop_queue(netdev);
>  
>  	atl1_clean_tx_ring(adapter);
>  	atl1_clean_rx_ring(adapter);
> @@ -3063,8 +3058,6 @@ static int __devinit atl1_probe(struct pci_dev
> *pdev, 
>  	atl1_pcie_patch(adapter);
>  	/* assume we have no link for now */
> -	netif_carrier_off(netdev);
> -	netif_stop_queue(netdev);
>  
>  	init_timer(&adapter->watchdog_timer);
>  	adapter->watchdog_timer.function = &atl1_watchdog;

Alexey,

Please ignore this patch.  It is unsavory fruit borne of abject
ignorance.

Jay
