From: David Miller <davem@davemloft.net>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 02:02:46 -0700 (PDT)
Message-ID: <20100415.020246.218622820.davem@davemloft.net>
References: <20100415.003711.159334670.davem@davemloft.net>
	<u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
	<1271321358.16881.2240.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757181Ab0DOJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 05:02:42 -0400
In-Reply-To: <1271321358.16881.2240.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Apr 2010 10:49:18 +0200

> Maybe we should add a new function after all...
> 
> int netif_rx_any(struct sk_buff *skb) 
> {
>        if (in_interrupt())
>                return netif_rx(skb);
> 
> 	return netif_rx_ni(skb);
> }

Ok, thanks for the analysis.

Since we keep coming back to this issue why don't we simply
solve it forever?  Let's make netif_rx() work in all contexts
and get rid of netif_rx_ni().

I think this is the thing to do because this whole netif_rx_ni()
vs. netif_rx() thing was meant to be an optimization of sorts (this
goes back to like 8+ years ago :-), and really I doubt it really
matters on that level any more.

What do you think?
