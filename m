From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: reset sk_err for ICMP packets read from
 error queue
Date: Fri, 02 Dec 2016 10:56:04 -0500 (EST)
Message-ID: <20161202.105604.570057839407725973.davem@davemloft.net>
References: <1480532468-1610-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, willemb@google.com,
        maze@google.com, hannes@stressinduktion.org, soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750862AbcLBP4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 10:56:06 -0500
In-Reply-To: <1480532468-1610-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Wed, 30 Nov 2016 14:01:08 -0500

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Only when ICMP packets are enqueued onto the error queue,
> sk_err is also set. Before f5f99309fa74 (sock: do not set sk_err
> in sock_dequeue_err_skb), a subsequent error queue read
> would set sk_err to the next error on the queue, or 0 if empty.
> As no error types other than ICMP set this field, sk_err should
> not be modified upon dequeuing them.
> 
> Only for ICMP errors, reset the (racy) sk_err. Some applications,
> like traceroute, rely on it and go into a futile busy POLLERR
> loop otherwise.
> 
> In principle, sk_err has to be set while an ICMP error is queued.
> Testing is_icmp_err_skb(skb_next) approximates this without
> requiring a full queue walk. Applications that receive both ICMP
> and other errors cannot rely on this legacy behavior, as other
> errors do not set sk_err in the first place.
> 
> Fixes: f5f99309fa74 (sock: do not set sk_err in sock_dequeue_err_skb)
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.
