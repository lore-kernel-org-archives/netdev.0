From: David Miller <davem@davemloft.net>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels
 >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 14:15:19 -0500 (EST)
Message-ID: <20130122.141519.767456896436365582.davem@davemloft.net>
References: <2166577.r0iRQtU7qE@cpaasch-mac>
	<3172160.NCYvLW6RVJ@cpaasch-mac>
	<1358872385.3464.3940.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, Ian.Campbell@citrix.com,
	sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab3AVTPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:15:21 -0500
In-Reply-To: <1358872385.3464.3940.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Jan 2013 08:33:05 -0800

> From: Eric Dumazet <edumazet@google.com>
 ...
> [PATCH] netxen: fix off by one bug in netxen_release_tx_buffer()
> 
> Christoph Paasch found netxen could trigger a BUG in its dismantle
> phase, in netxen_release_tx_buffer(), using full size TSO packets.
> 
> cmd_buf->frag_count includes the skb->data part, so the loop must
> start at index 1 instead of 0, or else we can make an out
> of bound access to cmd_buff->frag_array[MAX_SKB_FRAGS + 2]
> 
> Christoph provided the fixes in netxen_map_tx_skb() function.
> In case of a dma mapping error, its better to clear the dma fields
> so that we don't try to unmap them again in netxen_release_tx_buffer()
> 
> Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied and queued up for -stable, thanks.
