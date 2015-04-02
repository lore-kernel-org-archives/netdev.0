From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen-netfront: transmit fully GSO-sized packets
Date: Thu, 02 Apr 2015 16:19:33 -0400 (EDT)
Message-ID: <20150402.161933.1945119789363888240.davem@davemloft.net>
References: <1427796315-17655-1-git-send-email-jonathan.davies@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, wei.liu2@citrix.com, edumazet@google.com
To: jonathan.davies@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbDBUTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 16:19:40 -0400
In-Reply-To: <1427796315-17655-1-git-send-email-jonathan.davies@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Davies <jonathan.davies@citrix.com>
Date: Tue, 31 Mar 2015 11:05:15 +0100

> xen-netfront limits transmitted skbs to be at most 44 segments in size. However,
> GSO permits up to 65536 bytes, which means a maximum of 45 segments of 1448
> bytes each. This slight reduction in the size of packets means a slight loss in
> efficiency.
> 
> Since c/s 9ecd1a75d, xen-netfront sets gso_max_size to
>     XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER,
> where XEN_NETIF_MAX_TX_SIZE is 65535 bytes.
> 
> The calculation used by tcp_tso_autosize (and also tcp_xmit_size_goal since c/s
> 6c09fa09d) in determining when to split an skb into two is
>     sk->sk_gso_max_size - 1 - MAX_TCP_HEADER.
> 
> So the maximum permitted size of an skb is calculated to be
>     (XEN_NETIF_MAX_TX_SIZE - MAX_TCP_HEADER) - 1 - MAX_TCP_HEADER.
> 
> Intuitively, this looks like the wrong formula -- we don't need two TCP headers.
> Instead, there is no need to deviate from the default gso_max_size of 65536 as
> this already accommodates the size of the header.
> 
> Currently, the largest skb transmitted by netfront is 63712 bytes (44 segments
> of 1448 bytes each), as observed via tcpdump. This patch makes netfront send
> skbs of up to 65160 bytes (45 segments of 1448 bytes each).
> 
> Similarly, the maximum allowable mtu does not need to subtract MAX_TCP_HEADER as
> it relates to the size of the whole packet, including the header.
> 
> Fixes: 9ecd1a75d977 ("xen-netfront: reduce gso_max_size to account for max TCP header")
> Signed-off-by: Jonathan Davies <jonathan.davies@citrix.com>

Applied and queued up for -stable, thanks.
