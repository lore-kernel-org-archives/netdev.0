From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: ip_queue_rcv_skb() helper
Date: Wed, 28 Apr 2010 15:39:10 -0700 (PDT)
Message-ID: <20100428.153910.71562336.davem@davemloft.net>
References: <1272463605.2267.70.camel@edumazet-laptop>
	<20100428.143610.232922250.davem@davemloft.net>
	<1272493364.2201.67.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53124
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755513Ab0D1WjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 18:39:06 -0400
In-Reply-To: <1272493364.2201.67.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Apr 2010 00:22:44 +0200

> Next patch will try to not touch dst refcount in input path (previously
> attempted in July 2009)
> Ref : http://kerneltrap.org/mailarchive/linux-netdev/2009/7/22/6248753

Yes, I remember this.

> [PATCH net-next-2.6] net: ip_queue_rcv_skb() helper
> 
> When queueing a skb to socket, we can immediately release its dst if
> target socket do not use IP_CMSG_PKTINFO.
> 
> tcp_data_queue() can drop dst too.
> 
> This to benefit from a hot cache line and avoid the receiver, possibly
> on another cpu, to dirty this cache line himself.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Pretty soon the whole receive path will be "read mostly" :-)

Applied, thanks Eric.
