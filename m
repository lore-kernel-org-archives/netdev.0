From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: gso: do not generate out of order packets
Date: Thu, 16 May 2013 14:44:02 -0700 (PDT)
Message-ID: <20130516.144402.851927775820198853.davem@davemloft.net>
References: <1368668281.4519.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, therbert@google.com,
	ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462Ab3EPVoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 17:44:03 -0400
In-Reply-To: <1368668281.4519.75.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 May 2013 18:38:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> GSO TCP handler has following issues :
> 
> 1) ooo_okay from original GSO packet is duplicated to all segments
> 2) segments (but the last one) are orphaned, so transmit path can not
> get transmit queue number from the socket. This happens if GSO
> segmentation is done before stacked device for example.
> 
> Result is we can send packets from a given TCP flow to different TX
> queues (if using multiqueue NICS). This generates OOO problems and
> spurious SACK & retransmits.
> 
> Fix this by keeping socket pointer set for all segments.
> 
> This means that every segment must also have a destructor, and the
> original gso skb truesize must be split on all segments, to keep
> precise sk->sk_wmem_alloc accounting.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
