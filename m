From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: cpsw: improve interrupt lookup logic in
 cpsw_probe()
Date: Fri, 05 Sep 2014 17:17:30 -0700 (PDT)
Message-ID: <20140905.171730.1008773830841366831.davem@davemloft.net>
References: <1409814023-10189-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, netdev@vger.kernel.org, mugunthanvnm@ti.com,
	george.cherian@ti.com, zonque@gmail.com
To: daniel@zonque.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaIFARa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:17:30 -0400
In-Reply-To: <1409814023-10189-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@zonque.org>
Date: Thu,  4 Sep 2014 09:00:23 +0200

> From: Daniel Mack <zonque@gmail.com>
> 
> Simplify the interrupt resource lookup code in cpsw_probe() by the
> following:
> 
>  * Only look at the first member of the resource. As the driver only
>    works for DT-enabled platforms anyway, a resource of type
>    IORESOURCE_IRQ will only contain one single entry
>    (res->start == res->end), so there is no need for the iteration.
> 
>  * Add a bounds check to avoid overflows if we are passed more than
>    ARRAY_SIZE(priv->irqs_table) resources.
> 
>  * Assign 'ret' with the return value of devm_request_irq() so that
>    cpsw_probe() returns the appropriate error code.
> 
>  * If devm_request_irq() fails, report the error code in the log
>    message.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Applied to net-next, thanks.
