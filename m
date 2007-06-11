From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: Re: [PATCH 1/4] NetXen: Fix link status messages
Date: Mon, 11 Jun 2007 12:07:23 +0530
Message-ID: <200706111207.23445.mithlesh@netxen.com>
References: <200706071130.l57BUvcO007523@dut39.unminc.com> <466B2826.2060007@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:25658 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbXFKGhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 02:37:37 -0400
In-Reply-To: <466B2826.2060007@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 June 2007 03:52, Jeff Garzik wrote:
> Mithlesh Thukral wrote:
> > -	if ((netif_running(netdev)) && !netif_carrier_ok(netdev)) {
> > -		printk(KERN_INFO "%s port %d, %s carrier is now ok\n",
> > -		       netxen_nic_driver_name, adapter->portnum, netdev->name);
> > +	if ((netdev->flags & IFF_UP) && !netif_carrier_ok(netdev) &&
> > +			netxen_nic_link_ok(adapter) ) {
> > +		printk(KERN_INFO "%s %s (port %d), Link is up\n",
> > +			       netxen_nic_driver_name, netdev->name, adapter->portnum);
> >  		netif_carrier_on(netdev);
> > -	}
> > -
> > -	if (netif_queue_stopped(netdev))
> >  		netif_wake_queue(netdev);
> > +	} else if(!(netdev->flags & IFF_UP) && netif_carrier_ok(netdev)) {
> > +		printk(KERN_ERR "%s %s Link is Down\n",
> > +				netxen_nic_driver_name, netdev->name);
> > +		netif_carrier_off(netdev);
> > +		netif_stop_queue(netdev);
>
> Most of the patch is OK, but by substituting IFF_UP tests for
> netif_running(), you are removing race-free, correct tests and replacing
> them with incorrect, racy tests.
>
> NAK the IFF_UP changes.  the rest looks OK.
I will rework the IFF_UP tests using netif_running(), test and resubmit the 
patches again.

Thanks,
Mithlesh Thukral
>
> 	Jeff
