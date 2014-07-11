From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 79811] New: ethernet/dec/tulip/tulip_core.c:592: array
 index check in wrong place ?
Date: Thu, 10 Jul 2014 17:01:08 -0700 (PDT)
Message-ID: <20140710.170108.1244008191479717465.davem@davemloft.net>
References: <20140710055022.652ce61d@samsung-9>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbaGKABJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 20:01:09 -0400
In-Reply-To: <20140710055022.652ce61d@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 10 Jul 2014 05:50:22 -0700

> Subject: [Bug 79811] New: ethernet/dec/tulip/tulip_core.c:592: array index check in wrong place ?
 ...
> ethernet/dec/tulip/tulip_core.c:592]: (style) Array index 'j' is used before
> limits check.
> 
>             for (j = 0; buf[j] != 0xee && j < 1600; j++)
> 
> Suggest put limit check before index use.

This code has never actually ever been compiled for at least a decade
or two, it's ifdef protected against "way_too_many_messages" which
nothing will ever define.

This is what really eats me about automated tools sometimes, and in this case
I have two gripes:

1) The tool doesn't take into consideration that the code might never
   be compiled.

2) The code actually is buggy is far more important ways, it takes a DMA mapping
   cookie and dereferences it as a CPU pointer:

			u8 *buf = (u8 *)(tp->rx_ring[i].buffer1);

   which is guaranteed to not work.

So in actuality this entire code block should be rewritten or removed.
