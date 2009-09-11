From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: Re: [PATCH -next] netxen: build fix for INET=n
Date: Fri, 11 Sep 2009 15:46:29 -0700
Message-ID: <4AAAD345.4090902@qlogic.com>
References: <20090911154104.1804a82f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:35204 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbZIKWq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 18:46:27 -0400
In-Reply-To: <20090911154104.1804a82f.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

grr .. I broke it again!

Thanks Randy for fixing.

Acked-by: Dhananjay Phadke <dhananjay@netxen.com>

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> When CONFIG_INET is disabled, netxen has a build failure:
> 
> netxen_nic_main.c:(.text+0x118fd1): undefined reference to `netxen_config_indev_addr'
> 
> so make that function just an empty stub when CONFIG_INET=n.
> (not "inline" since that conflicts with other declarations of it)
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  drivers/net/netxen/netxen_nic_main.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> --- linux-next-20090911.orig/drivers/net/netxen/netxen_nic_main.c
> +++ linux-next-20090911/drivers/net/netxen/netxen_nic_main.c
> @@ -2450,6 +2450,10 @@ static struct notifier_block	netxen_netd
>  static struct notifier_block netxen_inetaddr_cb = {
>  	.notifier_call = netxen_inetaddr_event,
>  };
> +#else
> +static void
> +netxen_config_indev_addr(struct net_device *dev, unsigned long event)
> +{ }
>  #endif
>  
>  static struct pci_driver netxen_driver = {
> 
> 
> 
> 
> ---
> ~Randy
> LPC 2009, Sept. 23-25, Portland, Oregon
> http://linuxplumbersconf.org/2009/
