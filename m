From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] ipip: allow to deactivate the creation of
 fb dev
Date: Mon, 19 Nov 2012 19:06:48 -0500 (EST)
Message-ID: <20121119.190648.56478321385493529.davem@davemloft.net>
References: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
	<1353082456-21234-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541Ab2KTAGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:06:49 -0500
In-Reply-To: <1353082456-21234-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 16 Nov 2012 17:14:13 +0100

> Now that tunnels can be configured via rtnetlink, this device is not mandatory.
> The default is conservative.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I'm not too thrilled about this change, mostly because of my dislike of
module parameters in general.

But in this case there appears to be real bugs in the two sets of changes
where you add this setup_fb thing.

> @@ -1057,7 +1066,8 @@ static void __net_exit ipip_exit_net(struct net *net)
>  
>  	rtnl_lock();
>  	ipip_destroy_tunnels(ipn, &list);
> -	unregister_netdevice_queue(ipn->fb_tunnel_dev, &list);
> +	if (setup_fb)
> +		unregister_netdevice_queue(ipn->fb_tunnel_dev, &list);
>  	unregister_netdevice_many(&list);
>  	rtnl_unlock();
>  }

Users can modify module parameter values via sysfs after the module
is loaded, so you need a more internal and protected state to use
to decide whether you really need to unregister the thing or not.

But to me it's just symptomatic of what a bad idea this is in the
first place.
