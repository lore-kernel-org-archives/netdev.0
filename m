From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] lan78xx: Fix Smatch warnings
Date: Sun, 09 Aug 2015 22:43:18 -0700 (PDT)
Message-ID: <20150809.224318.1435549728086593846.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D53BF06@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbbHJFnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 01:43:19 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D53BF06@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Wed, 5 Aug 2015 21:26:14 +0000

> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index ec8bd34..3ac405f 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -291,7 +291,7 @@ static int lan78xx_read_reg(struct lan78xx_net *dev, u32 index, u32 *data)
>  	u32 *buf = kmalloc(sizeof(u32), GFP_KERNEL);
>  	int ret;
>  
> -	BUG_ON(!dev);
> +	WARN_ON_ONCE(!dev);
>  

The debugging check makes no sense at all if you aren't going to crash
immediately due to it.

The subsequent dereference of dev will cause a crash anyways.

So if you're going to change this at all, just kill all of these
NULL pointer debug checks, as they are completely pointless.
