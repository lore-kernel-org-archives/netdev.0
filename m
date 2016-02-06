From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] r8169: Add bios support.
Date: Sat, 06 Feb 2016 02:39:32 -0500 (EST)
Message-ID: <20160206.023932.2140900219779859048.davem@davemloft.net>
References: <1454740286-4738-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: asd@marian1000.go.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcBFHji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 02:39:38 -0500
In-Reply-To: <1454740286-4738-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <asd@marian1000.go.ro>
Date: Sat,  6 Feb 2016 08:31:26 +0200

> @@ -8262,8 +8262,9 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	rtl_hw_reset(tp);
>  
>  	rtl_ack_events(tp, 0xffff);
> -
> +#ifndef CONFIG_BIOS_SUPPORT
>  	pci_set_master(pdev);
> +#endif

I already made it clear to you that it is perfectly fine to unconditionally
call pci_set_master() from the driver in any circumstance.

Look across all of the drivers under drivers/net/ that invoke this function,
it's meant to be used this way and it's fine.

There is absolutely no reason to conditionalize it.

Thanks.
