From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gro: avoid reorders
Date: Wed, 09 Nov 2016 18:50:00 -0500 (EST)
Message-ID: <20161109.185000.45567817803684243.davem@davemloft.net>
References: <1478545947.17367.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44682 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbcKIXuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 18:50:02 -0500
In-Reply-To: <1478545947.17367.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Nov 2016 11:12:27 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Receiving a GSO packet in dev_gro_receive() is not uncommon
> in stacked devices, or devices partially implementing LRO/GRO
> like bnx2x. GRO is implementing the aggregation the device
> was not able to do itself.
> 
> Current code causes reorders, like in following case :
> 
> For a given flow where sender sent 3 packets P1,P2,P3,P4
> 
> Receiver might receive P1 as a single packet, stored in GRO engine.
> 
> Then P2-P4 are received as a single GSO packet, immediately given to
> upper stack, while P1 is held in GRO engine.
> 
> This patch will make sure P1 is given to upper stack, then P2-P4
> immediately after.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
