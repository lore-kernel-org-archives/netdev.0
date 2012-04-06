From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 27/39] smsc9420: stop using
 net_device.{base_addr, irq}.
Date: Fri, 06 Apr 2012 06:23:51 -0400 (EDT)
Message-ID: <20120406.062351.247404412856760540.davem@davemloft.net>
References: <1333704408.git.romieu@fr.zoreil.com>
	<722b2708e6b621a33fe8f778ea35e1f0ddb4636a.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845Ab2DFKY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 06:24:56 -0400
In-Reply-To: <722b2708e6b621a33fe8f778ea35e1f0ddb4636a.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri,  6 Apr 2012 12:06:41 +0200

> -	if (request_irq(dev->irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
> -			DRV_NAME, pd)) {
> -		smsc_warn(IFUP, "Unable to use IRQ = %d", dev->irq);
> -		result = -ENODEV;
> +	result = request_irq(irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
> +			     DRV_NAME, pd);
> +	if (result < 0) {
> +		smsc_warn(IFUP, "Unable to use IRQ = %d", irq);

Another case where you should preserve the nature of
the test, make this "if (result)"
