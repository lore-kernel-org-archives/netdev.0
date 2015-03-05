From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: bcmgenet: simplify
 __bcmgenet_tx_reclaim()
Date: Wed, 04 Mar 2015 23:55:25 -0500 (EST)
Message-ID: <20150304.235525.768945224673443511.davem@davemloft.net>
References: <20150304223002.0233E22021A@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbbCEEz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:55:27 -0500
In-Reply-To: <20150304223002.0233E22021A@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Wed,  4 Mar 2015 14:30:01 -0800 (PST)

> 1. Use c_index and ring->c_index to determine how many TxCBs/TxBDs are
>    ready for cleanup
>    - c_index = the current value of TDMA_CONS_INDEX
>    - TDMA_CONS_INDEX is HW-incremented and auto-wraparound (0x0-0xFFFF)
>    - ring->c_index = __bcmgenet_tx_reclaim() cleaned up to this point on
>      the previous invocation
> 
> 2. Add bcmgenet_tx_ring->clean_ptr
>    - index of the next TxCB to be cleaned
>    - incremented as TxCBs/TxBDs are processed
>    - value always in range [ring->cb_ptr, ring->end_ptr]
> 
> 3. Fix incrementing of dev->stats.tx_packets
>    - should be incremented only when tx_cb_ptr->skb != NULL
> 
> These changes simplify __bcmgenet_tx_reclaim(). Furthermore, Tx ring size
> can now be any value.
> 
> With the old code, Tx ring size had to be a power-of-2:
>    num_tx_bds = ring->size;
>    c_index &= (num_tx_bds - 1);
>    last_c_index &= (num_tx_bds - 1);
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied, thanks.
