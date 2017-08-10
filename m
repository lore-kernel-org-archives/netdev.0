From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: consistently apply ufo or fragmentation
Date: Thu, 10 Aug 2017 09:52:26 -0700 (PDT)
Message-ID: <20170810.095226.1892134367440824522.davem@davemloft.net>
References: <20170810162919.50577-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@gmail.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752460AbdHJQw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:52:27 -0400
In-Reply-To: <20170810162919.50577-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu, 10 Aug 2017 12:29:19 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> When iteratively building a UDP datagram with MSG_MORE and that
> datagram exceeds MTU, consistently choose UFO or fragmentation.
> 
> Once skb_is_gso, always apply ufo. Conversely, once a datagram is
> split across multiple skbs, do not consider ufo.
> 
> Sendpage already maintains the first invariant, only add the second.
> IPv6 does not have a sendpage implementation to modify.
> 
> A gso skb must have a partial checksum, do not follow sk_no_check_tx
> in udp_send_skb.
> 
> Found by syzkaller.
> 
> Fixes: e89e9cf539a2 ("[IPv4/IPv6]: UFO Scatter-gather approach")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable.
