From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sat, 24 Jul 2010 21:06:56 -0700 (PDT)
Message-ID: <20100724.210656.48510854.davem@davemloft.net>
References: <20100722191234.GA832@cronus.persephoneslair.org>
	<1279861748.2482.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrea@persephoneslair.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49256
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750919Ab0GYEGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 00:06:39 -0400
In-Reply-To: <1279861748.2482.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Jul 2010 07:09:08 +0200

> [PATCH net-next-2.6] net: pskb_expand_head() optimization
> 
> Move frags[] at the end of struct skb_shared_info, and make
> pskb_expand_head() copy only the used part of it instead of whole array.
> 
> This should avoid kmemcheck warnings and speedup pskb_expand_head() as
> well, avoiding a lot of cache misses.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Maybe it's just that people aren't running kmemcheck when a
pskb_expand_head() triggers, who knows.

Anyways, since we skip the ->frag[] array in skb alloc, etc.,
your patch is of course fine.

Applied, thanks!
