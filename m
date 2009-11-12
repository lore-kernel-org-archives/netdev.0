From: Wang Chen <ellre923@gmail.com>
Subject: Re: [patch] missing dev_put() on error path in vif_add()
Date: Thu, 12 Nov 2009 10:50:02 +0800
Message-ID: <4AFB77DA.3040600@gmail.com>
References: <alpine.DEB.2.00.0911111339100.9485@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:62121 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760029AbZKLC5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 21:57:39 -0500
Received: by pwi3 with SMTP id 3so1073635pwi.21
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 18:57:44 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.0911111339100.9485@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter said the following on 2009-11-11 20:03:
> The other error paths in front of this one have a dev_put() but this one 
> got missed.
> 
> Found by smatch static checker.
> 
> regards,
> dan carpenter
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> --- orig/net/ipv4/ipmr.c	2009-11-11 13:34:20.000000000 +0200
> +++ devel/net/ipv4/ipmr.c	2009-11-11 13:34:59.000000000 +0200
> @@ -483,8 +483,10 @@
>  		return -EINVAL;
>  	}
>  
> -	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
> +	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL) {
> +		dev_put(dev);
>  		return -EADDRNOTAVAIL;
> +	}
>  	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
>  	ip_rt_multicast_event(in_dev);
>  

It's my fault. Introduced in 7dc00c82cbb0119cf4663f65bbaa2cc55f961db2.

Acked-by: Wang Chen <ellre923@gmail.com>
