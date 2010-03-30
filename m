From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/pcmcia 3com: replacements of printk() with
 dev_info() and friends (fwd)
Date: Tue, 30 Mar 2010 10:22:13 -0700
Message-ID: <1269969733.4558.171.camel@Joe-Laptop.home>
References: <alpine.DEB.1.10.1003302019200.11637@blala.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ken Kawasaki <ken_kawasaki@spring.nifty.jp>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Magnus Damm <damm@opensource.se>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Kurz <akurz@blala.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1259 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754874Ab0C3RWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 13:22:15 -0400
In-Reply-To: <alpine.DEB.1.10.1003302019200.11637@blala.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-30 at 21:01 +0400, Alexander Kurz wrote:
>   I wrote a patch as suggested by kernel-janitors.
>   It is my first patch, so I highly welcome comments and hints,
>   thanks, Alexander Kurz

As this is a network driver, you could use netdev_<level>
for most of this.  Also, you could coalesce the format
strings to go beyond 80 columns.  It makes grepping
a bit easier.

> -	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, "
> +	dev_info(&dev->dev, "%s: %s at io %#3lx, irq %d, "
>   	       "hw_addr %pM.\n",

This could become:

	netdev_info(dev, "%s at io %#3lx, irq %d, hw_addr %pM\n"
		    cardname, dev->base_addr, dev->irq, dev->dev_addr);

etc.


