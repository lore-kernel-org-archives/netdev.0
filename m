From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] lan78xx: Use irq_domain for phy interrupt
 from USB Int. EP
Date: Tue, 01 Nov 2016 12:03:22 -0400 (EDT)
Message-ID: <20161101.120322.716031785792281107.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D4095CACB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752381AbcKAQD1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:03:27 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4095CACB@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Mon, 31 Oct 2016 21:44:37 +0000

> @@ -2668,6 +2821,13 @@ static int lan78xx_bind(struct lan78xx_net *dev, struct usb_interface *intf)
>  
>  	dev->net->hw_features = dev->net->features;
>  
> +	ret = lan78xx_setup_irq_domain(dev);
> +	if (ret < 0) {
> +		netdev_warn(dev->net,
> +			    "lan78xx_setup_irq_domain() failed : %d", ret);
> +		return ret;
> +	}
> +

This error path leaks the memory allocated at the beginning of this function.

That would normally be freed up by lan78xx_unbind() but the caller will not
invoke that if lan78xx_bind() fails so you have to take care of the kfree
here.
