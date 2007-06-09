From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] NetXen: Fix link status messages
Date: Sat, 09 Jun 2007 18:22:30 -0400
Message-ID: <466B2826.2060007@garzik.org>
References: <200706071130.l57BUvcO007523@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35118 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755164AbXFIWWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:22:32 -0400
In-Reply-To: <200706071130.l57BUvcO007523@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> -	if ((netif_running(netdev)) && !netif_carrier_ok(netdev)) {
> -		printk(KERN_INFO "%s port %d, %s carrier is now ok\n",
> -		       netxen_nic_driver_name, adapter->portnum, netdev->name);
> +	if ((netdev->flags & IFF_UP) && !netif_carrier_ok(netdev) &&
> +			netxen_nic_link_ok(adapter) ) {
> +		printk(KERN_INFO "%s %s (port %d), Link is up\n",
> +			       netxen_nic_driver_name, netdev->name, adapter->portnum);
>  		netif_carrier_on(netdev);
> -	}
> -
> -	if (netif_queue_stopped(netdev))
>  		netif_wake_queue(netdev);
> +	} else if(!(netdev->flags & IFF_UP) && netif_carrier_ok(netdev)) {
> +		printk(KERN_ERR "%s %s Link is Down\n",
> +				netxen_nic_driver_name, netdev->name);
> +		netif_carrier_off(netdev);
> +		netif_stop_queue(netdev);


Most of the patch is OK, but by substituting IFF_UP tests for 
netif_running(), you are removing race-free, correct tests and replacing 
them with incorrect, racy tests.

NAK the IFF_UP changes.  the rest looks OK.

	Jeff


