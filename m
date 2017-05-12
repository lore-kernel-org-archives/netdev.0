From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: avoid fragmenting peculiar skbs in SACK
Date: Thu, 11 May 2017 21:36:09 -0400 (EDT)
Message-ID: <20170511.213609.1826897036363570671.davem@davemloft.net>
References: <20170511000127.4249-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757342AbdELBgL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 21:36:11 -0400
In-Reply-To: <20170511000127.4249-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 10 May 2017 17:01:27 -0700

> This patch fixes a bug in splitting an SKB during SACK
> processing. Specifically if an skb contains multiple
> packets and is only partially sacked in the higher sequences,
> tcp_match_sack_to_skb() splits the skb and marks the second fragment
> as SACKed.
> 
> The current code further attempts rounding up the first fragment
> to MSS boundaries. But it misses a boundary condition when the
> rounded-up fragment size (pkt_len) is exactly skb size.  Spliting
> such an skb is pointless and causses a kernel warning and aborts
> the SACK processing. This patch universally checks such over-split
> before calling tcp_fragment to prevent these unnecessary warnings.
> 
> Fixes: adb92db857ee ("tcp: Make SACK code to split only at mss boundaries")
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Hehe, a 2.6.29 bug, funny that it lived for so long.

Applied and queued up for -stable, thanks!
