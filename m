From: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Subject: Re: [PATCH] ipv6: by default join ff01::1 and in case of forwarding
 ff01::2 and ff05:2
Date: Sun, 10 Feb 2013 23:47:34 +0900
Message-ID: <5117B306.4070402@yoshifuji.org>
References: <20130210133431.GD18219@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:34517 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759190Ab3BJOrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 09:47:37 -0500
In-Reply-To: <20130210133431.GD18219@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -611,10 +617,15 @@ static void dev_forward_change(struct inet6_dev *idev)
>  	if (idev->cnf.forwarding)
>  		dev_disable_lro(dev);
>  	if (dev->flags & IFF_MULTICAST) {
> -		if (idev->cnf.forwarding)
> +		if (idev->cnf.forwarding) {
>  			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
> -		else
> +			ipv6_dev_mc_inc(dev, &in6addr_interfacelocal_allrouters);
> +			ipv6_dev_mc_inc(dev, &in6addr_sitelocal_allrouters);
> +		} else {
>  			ipv6_dev_mc_dec(dev, &in6addr_linklocal_allrouters);
> +			ipv6_dev_mc_dec(dev, &in6addr_interfacelocal_allrouters);
> +			ipv6_dev_mc_inc(dev, &in6addr_sitelocal_allrouters);
                                    ~~~dec?
> +		}
>  	}

--yoshfuji
