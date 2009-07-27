From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lmc: Read outside array bounds
Date: Sun, 26 Jul 2009 18:33:26 -0700 (PDT)
Message-ID: <20090726.183326.52668550.davem@davemloft.net>
References: <4A6B84A9.7020506@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754296AbZG0BdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 21:33:19 -0400
In-Reply-To: <4A6B84A9.7020506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 26 Jul 2009 00:18:17 +0200

> if dev_alloc_skb() fails on the first iteration of the allocation loop, and we
> break out of the loop, then we end up writing before the start of the array.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
...
>                  sc->failed_ring = 1;
> -                break;
> +                return;

This won't work.

First of all, if we allocated at least one buffer we should
mark the last one in the code right after this loop.

Second of all, we should purge the TX skbs in the next
loop even if we could not allocate even one RX buffer.

The thing to do is probably to guard the set of "[i-1]" RX ring
accesses with a "if (i != 0)" check.
