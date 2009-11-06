From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip_frag:
Date: Thu, 05 Nov 2009 21:08:27 -0800 (PST)
Message-ID: <20091105.210827.137296827.davem@davemloft.net>
References: <4AF1F809.4090903@gmail.com>
	<1257372051.24051.8.camel@Joe-Laptop.home>
	<4AF1FC25.9090006@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754080AbZKFFIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:08:02 -0500
In-Reply-To: <4AF1FC25.9090006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 23:11:49 +0100

> [PATCH net-next-2.6] ip_frag: dont touch device refcount
> 
> When sending fragmentation expiration ICMP V4/V6 messages,
> we can avoid touching device refcount, thanks to RCU
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6

Although I was worried a little bit initially about the
ipv4 case, as we're assigning the device pointer to
"skb->dev" and I thought it might be troublesome for
that reference to escape.

But that seems ok, because icmp_send() doesn't do anything interesting
with it's 'skb_in' arg other than look at the attached route, the
packet contents, and things like that.

Thanks.
