From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: systemport: Use eth_hw_addr_random
Date: Thu, 09 Jul 2015 14:31:11 -0700
Message-ID: <559EE81F.20900@gmail.com>
References: <20150708051930.GA13317@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Vaishali Thakkar <vthakkar1994@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36075 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754080AbbGIVcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 17:32:55 -0400
In-Reply-To: <20150708051930.GA13317@vaishali-Ideapad-Z570>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/15 22:19, Vaishali Thakkar wrote:
> Use eth_hw_addr_random() instead of calling random_ether_addr().
> Here, this change is setting addr_assign_type to NET_ADDR_RANDOM.
> 
> The Coccinelle semantic patch that performs this transformation
> is as follows:
> 
> @@
> identifier a,b;
> @@
> 
> -random_ether_addr(a->b);
> +eth_hw_addr_random(a);
> 
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Tested-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> Note that this patch is compile tested only and I have used file
> drivers/net/ethernet/hisilicon/hix5hd2_gmac.c as a reference.
> Also, original call didn't make assignment to NET_ADDR_RANDOM. So,
> it would be good if someone can test this change.
> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index 909ad7a..4566cdf 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -1793,7 +1793,7 @@ static int bcm_sysport_probe(struct platform_device *pdev)
>  	macaddr = of_get_mac_address(dn);
>  	if (!macaddr || !is_valid_ether_addr(macaddr)) {
>  		dev_warn(&pdev->dev, "using random Ethernet MAC\n");
> -		random_ether_addr(dev->dev_addr);
> +		eth_hw_addr_random(dev);
>  	} else {
>  		ether_addr_copy(dev->dev_addr, macaddr);
>  	}
> 


-- 
Florian
