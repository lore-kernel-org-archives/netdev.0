From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] drivers: net: Don't print unpopulated net_device
 name
Date: Wed, 11 May 2016 19:26:31 -0400 (EDT)
Message-ID: <20160511.192631.759104843385712307.davem@davemloft.net>
References: <1462898601-5429-1-git-send-email-harvey.hunt@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.jarzmik@free.fr, Baohua.Song@csr.com, marcel@ziswiler.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: harvey.hunt@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbcEKX0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:26:33 -0400
In-Reply-To: <1462898601-5429-1-git-send-email-harvey.hunt@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Hunt <harvey.hunt@imgtec.com>
Date: Tue, 10 May 2016 17:43:21 +0100

> @@ -1686,8 +1686,7 @@ dm9000_probe(struct platform_device *pdev)
>  	}
>  
>  	if (!is_valid_ether_addr(ndev->dev_addr)) {
> -		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
> -			 "set using ifconfig\n", ndev->name);
> +		dev_warn(db->dev, "Invalid ethernet MAC address. Please set using ifconfig\n");
>  
>  		eth_hw_addr_random(ndev);
>  		mac_src = "random";

If we don't print the netdev name, it's harder for the user to see which
adapter has the problem.

Therefore, it is better if you save some boolean state into a local variable
here, then print the warning right after register_netdev().

Likewise for the rest of your changes too.
