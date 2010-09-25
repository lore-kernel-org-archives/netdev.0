From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when
 able to sleep
Date: Sat, 25 Sep 2010 00:13:00 -0700 (PDT)
Message-ID: <20100925.001300.193725148.davem@davemloft.net>
References: <20100924222434.GA7743@electric-eye.fr.zoreil.com>
	<20100924.223709.233700415.davem@davemloft.net>
	<1285394797.2478.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sgruszka@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42417
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751472Ab0IYHMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 03:12:41 -0400
In-Reply-To: <1285394797.2478.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 25 Sep 2010 08:06:37 +0200

> Patch solves the suspend/resume, probably, but as soon as we receive
> trafic, we can hit the allocation error anyway...

It allocates 1536 + N, where N can be NET_IP_ALIGN, or some small
value like 8.

This is in the same ballpark as what tg3 allocates for RX buffers.

SLAB/SLUB/whatever just wants multi-order page allocations even
for SKBs which are about this size.

Furthermore, the sleeping allocations we do at ->open() time to
allocate the entire RX ring all at once will buddy up a lot of
pages and make 1-order allocs more likely.
