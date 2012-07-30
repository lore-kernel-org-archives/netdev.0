From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: TCP early demux cleanup
Date: Mon, 30 Jul 2012 14:54:31 -0700 (PDT)
Message-ID: <20120730.145431.2139785588993125881.davem@davemloft.net>
References: <1343631973.2626.13317.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633Ab2G3Vyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 17:54:32 -0400
In-Reply-To: <1343631973.2626.13317.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Jul 2012 09:06:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> early_demux() handlers should be called in RCU context, and as we
> use skb_dst_set_noref(skb, dst), caller must not exit from RCU context
> before dst use (skb_dst(skb)) or release (skb_drop(dst))
> 
> Therefore, rcu_read_lock()/rcu_read_unlock() pairs around
> ->early_demux() are confusing and not needed :
> 
> Protocol handlers are already in an RCU read lock section.
> (__netif_receive_skb() does the rcu_read_lock() )
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I wondered about this very issue when I wrote this code, thanks
for clearing things up.

Applied.
