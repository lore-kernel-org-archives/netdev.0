From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: davinci_mdio: use builtin_platform_driver
Date: Fri, 25 Nov 2016 16:23:57 -0500 (EST)
Message-ID: <20161125.162357.1584801226397085201.davem@davemloft.net>
References: <055763562f90fd7e2d311308e1d731ba93c3eea9.1479912302.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751261AbcKYVZe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 16:25:34 -0500
In-Reply-To: <055763562f90fd7e2d311308e1d731ba93c3eea9.1479912302.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geliang Tang <geliangtang@gmail.com>
Date: Wed, 23 Nov 2016 22:45:43 +0800

> @@ -536,11 +536,7 @@ static struct platform_driver davinci_mdio_driver = {
>  	.remove = davinci_mdio_remove,
>  };
>  
> -static int __init davinci_mdio_init(void)
> -{
> -	return platform_driver_register(&davinci_mdio_driver);
> -}
> -device_initcall(davinci_mdio_init);
> +builtin_platform_driver(davinci_mdio_driver);
>  

As noted by others this is not a correct transformation, the existing
code works properly when modular.  But it will not with this change.

device_initcall() is rerouted to module_init() inside of a module
build, whereas the thing builtin_platform_driver() expands to does
not.
