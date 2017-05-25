From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: avoid fastopen API to be used on AF_UNSPEC
Date: Thu, 25 May 2017 13:30:59 -0400 (EDT)
Message-ID: <20170525.133059.164631008796124539.davem@davemloft.net>
References: <20170524165931.22502-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com,
        vegard.nossum@oracle.com, edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424846AbdEYRbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:31:02 -0400
In-Reply-To: <20170524165931.22502-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Wed, 24 May 2017 09:59:31 -0700

> Fastopen API should be used to perform fastopen operations on the TCP
> socket. It does not make sense to use fastopen API to perform disconnect
> by calling it with AF_UNSPEC. The fastopen data path is also prone to
> race conditions and bugs when using with AF_UNSPEC.
> 
> One issue reported and analyzed by Vegard Nossum is as follows:
 ...
> If the connection is reopened then we will send a brand new SYN packet
> after thread A has already queued a buffer. At this point I think the
> socket internal state (sequence numbers etc.) becomes messed up.
> 
> When the new connection is closed, the FIN-ACK is rejected because the
> sequence number is outside the window. The other side tries to
> retransmit,
> but __tcp_retransmit_skb() calls tcp_trim_head() on an empty skb which
> corrupts the skb data length and hits a BUG() in copy_and_csum_bits().
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> 
> Hence, this patch adds a check for AF_UNSPEC in the fastopen data path
> and return EOPNOTSUPP to user if such case happens.
> 
> Fixes: cf60af03ca4e7 ("tcp: Fast Open client - sendmsg(MSG_FASTOPEN)")
> Reported-by: Vegard Nossum <vegard.nossum@oracle.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queue up for -stable, thanks.
