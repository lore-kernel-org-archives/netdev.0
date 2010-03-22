From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: rps: Fix build with CONFIG_SYSFS enabled
Date: Mon, 22 Mar 2010 14:48:47 -0700
Message-ID: <4BA7E5BF.1080805@oracle.com>
References: <alpine.DEB.1.00.1003221355380.25849@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:32972 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756424Ab0CVVtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 17:49:01 -0400
In-Reply-To: <alpine.DEB.1.00.1003221355380.25849@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/10 13:57, Tom Herbert wrote:
> Fix build with CONFIG_SYSFS not enabled.
> 
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 7a46343..f6b6bfe 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -739,7 +739,9 @@ void netdev_unregister_kobject(struct net_device * net)
>  	if (!net_eq(dev_net(net), &init_net))
>  		return;
>  
> +#ifdef CONFIG_SYSFS
>  	rx_queue_remove_kobjects(net);
> +#endif
>  
>  	device_del(dev);
>  }
> @@ -780,11 +782,13 @@ int netdev_register_kobject(struct net_device *net)
>  	if (error)
>  		return error;
>  
> +#ifdef CONFIG_SYSFS
>  	error = rx_queue_register_kobjects(net);
>  	if (error) {
>  		device_del(dev);
>  		return error;
>  	}
> +#endif
>  
>  	return error;
>  }
> 
> --

Dave, this patch and Eric's patch both build OK.  Your choice...

-- 
~Randy
