From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] rose_route_frame() NULL pointer dereference kernel
 panic
Date: Thu, 25 Feb 2016 17:09:57 -0500 (EST)
Message-ID: <20160225.170957.836114237953219422.davem@davemloft.net>
References: <56CDDFF7.2040609@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org
To: f6bvp@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbcBYWJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 17:09:59 -0500
In-Reply-To: <56CDDFF7.2040609@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: f6bvp <f6bvp@free.fr>
Date: Wed, 24 Feb 2016 17:53:11 +0100

> @@ -863,6 +863,11 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb
> *ax25)

First of all this patch was corrupted by your email client.

>         int res = 0;
>         char buf[11];
> 
> +       if (ax25 == NULL) {
> +               printk("Null ax25 destination !\n");
> +               return res;
> +       }

Second of all, this log message is not appropriate, especially given that
rose_xmit() calls rose_rout_frame() with an explicit NULL second argument.
