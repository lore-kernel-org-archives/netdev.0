From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: neighbour: prohibit negative value
 for unres_qlen_bytes parameter
Date: Wed, 05 Dec 2012 16:26:05 -0500 (EST)
Message-ID: <20121205.162605.1922207208186317600.davem@davemloft.net>
References: <50BED24B.1030205@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shanwei88@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab2LEV0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:26:07 -0500
In-Reply-To: <50BED24B.1030205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei88@gmail.com>
Date: Wed, 05 Dec 2012 12:49:15 +0800

> From: Shan Wei <davidshan@tencent.com>
> 
> unres_qlen_bytes and unres_qlen are int type.
> But multiple relation(unres_qlen_bytes = unres_qlen * SKB_TRUESIZE(ETH_FRAME_LEN))
> will cause type overflow when seting unres_qlen. e.g.
> 
> $ echo 1027506 > /proc/sys/net/ipv4/neigh/eth1/unres_qlen
> $ cat /proc/sys/net/ipv4/neigh/eth1/unres_qlen
> 1182657265
> $ cat /proc/sys/net/ipv4/neigh/eth1/unres_qlen_bytes 
> -2147479756
> 
> The gutted value is not that we setting。
> But user/administrator don't know this is caused by int type overflow.
> 
> what's more, it is meaningless and even dangerous that unres_qlen_bytes is set
> with negative number. Because, for unresolved neighbour address, kernel will cache packets
> without limit in __neigh_event_send()(e.g. (u32)-1 = 2GB).
> 
> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>

Applied.
