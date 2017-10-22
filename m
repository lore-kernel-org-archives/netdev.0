From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock: correct sk_wmem_queued accounting on efault
 in tcp zerocopy
Date: Sun, 22 Oct 2017 01:52:00 +0100 (WEST)
Message-ID: <20171022.015200.2223977227108729125.davem@davemloft.net>
References: <20171019164039.20927-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932269AbdJVAwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 20:52:03 -0400
In-Reply-To: <20171019164039.20927-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu, 19 Oct 2017 12:40:39 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Syzkaller hits WARN_ON(sk->sk_wmem_queued) in sk_stream_kill_queues
> after triggering an EFAULT in __zerocopy_sg_from_iter.
> 
> On this error, skb_zerocopy_stream_iter resets the skb to its state
> before the operation with __pskb_trim. It cannot kfree_skb like
> datagram callers, as the skb may have data from a previous send call.
> 
> __pskb_trim calls skb_condense for unowned skbs, which adjusts their
> truesize. These tcp skbuffs are owned and their truesize must add up
> to sk_wmem_queued. But they match because their skb->sk is NULL until
> tcp_transmit_skb.
> 
> Temporarily set skb->sk when calling __pskb_trim to signal that the
> skbuffs are owned and avoid the skb_condense path.
> 
> Fixes: 52267790ef52 ("sock: add MSG_ZEROCOPY")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
