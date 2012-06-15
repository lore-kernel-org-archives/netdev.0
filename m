From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove skb_orphan_try()
Date: Fri, 15 Jun 2012 15:31:21 -0700 (PDT)
Message-ID: <20120615.153121.2111795723533328140.davem@davemloft.net>
References: <1339668471.22704.714.camel@edumazet-glaptop>
	<20120614.033153.258221733380821664.davem@davemloft.net>
	<1339692164.7491.64.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhautbois@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758318Ab2FOWbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 18:31:22 -0400
In-Reply-To: <1339692164.7491.64.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Jun 2012 18:42:44 +0200

> [PATCH] net: remove skb_orphan_try()
> 
> Orphaning skb in dev_hard_start_xmit() makes bonding behavior
> unfriendly for applications sending big UDP bursts : Once packets
> pass the bonding device and come to real device, they might hit a full
> qdisc and be dropped. Without orphaning, the sender is automatically
> throttled because sk->sk_wmemalloc reaches sk->sk_sndbuf (assuming
> sk_sndbuf is not too big)
> 
> We could try to defer the orphaning adding another test in
> dev_hard_start_xmit(), but all this seems of little gain,
> now that BQL tends to make packets more likely to be parked
> in Qdisc queues instead of NIC TX ring, in cases where performance
> matters.
> 
> Reverts commits :
> fc6055a5ba31 net: Introduce skb_orphan_try()
> 87fd308cfc6b net: skb_tx_hash() fix relative to skb_orphan_try()
> and removes SKBTX_DRV_NEEDS_SK_REF flag
> 
> Reported-and-bisected-by: Jean-Michel Hautbois <jhautbois@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
