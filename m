From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp: fix freeing skb too early for IPV6_RECVPKTINFO
Date: Fri, 17 Feb 2017 13:37:08 -0500 (EST)
Message-ID: <20170217.133708.1915562990938384609.davem@davemloft.net>
References: <20170216162246.12783-1-andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, gerrit@erg.abdn.ac.uk,
        dvyukov@google.com, kcc@google.com, glider@google.com
To: andreyknvl@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934654AbdBQShK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:37:10 -0500
In-Reply-To: <20170216162246.12783-1-andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 16 Feb 2017 17:22:46 +0100

> In the current DCCP implementation an skb for a DCCP_PKT_REQUEST packet
> is forcibly freed via __kfree_skb in dccp_rcv_state_process if
> dccp_v6_conn_request successfully returns.
> 
> However, if IPV6_RECVPKTINFO is set on a socket, the address of the skb
> is saved to ireq->pktopts and the ref count for skb is incremented in
> dccp_v6_conn_request, so skb is still in use. Nevertheless, it gets freed
> in dccp_rcv_state_process.
> 
> Fix by calling consume_skb instead of doing goto discard and therefore
> calling __kfree_skb.
> 
> Similar fixes for TCP:
> 
> fb7e2399ec17f1004c0e0ccfd17439f8759ede01 [TCP]: skb is unexpectedly freed.
> 0aea76d35c9651d55bbaf746e7914e5f9ae5a25d tcp: SYN packets are now
> simply consumed
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks.
