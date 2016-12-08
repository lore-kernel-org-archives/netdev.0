From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 net-next 1/4] udp: add busylocks in RX path
Date: Thu, 08 Dec 2016 20:45:50 +0100
Message-ID: <1481226350.1892859.812996409.6D78D4D7@webmail.messagingengine.com>
References: <1481226117-31288-1-git-send-email-edumazet@google.com>
 <1481226117-31288-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:34173 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752030AbcLHTpv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:45:51 -0500
In-Reply-To: <1481226117-31288-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Dec 8, 2016, at 20:41, Eric Dumazet wrote:
> Idea of busylocks is to let producers grab an extra spinlock
> to relieve pressure on the receive_queue spinlock shared by consumer.
> 
> This behavior is requested only once socket receive queue is above
> half occupancy.
> 
> Under flood, this means that only one producer can be in line
> trying to acquire the receive_queue spinlock.
> 
> These busylock can be allocated on a per cpu manner, instead of a
> per socket one (that would consume a cache line per socket)
> 
> This patch considerably improves UDP behavior under stress,
> depending on number of NIC RX queues and/or RPS spread.

This patch mostly improves situation for non-connected sockets. Do you
think it makes sense to acquire the spinlock depending on the sockets
state? Connected UDP sockets flow in on one CPU anyway?

Otherwise the series looks really great, thanks!
