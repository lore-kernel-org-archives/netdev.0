From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/2] net: bcmgenet: fix dev->stats.tx_bytes
 accounting
Date: Thu, 24 Mar 2016 15:15:19 -0400 (EDT)
Message-ID: <20160324.151519.1184406640007918441.davem@davemloft.net>
References: <1458844041-71532-1-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	jaedon.shin@gmail.com, edumazet@google.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbcCXTPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 15:15:22 -0400
In-Reply-To: <1458844041-71532-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Thu, 24 Mar 2016 11:27:20 -0700

> 1. Add bytes_compl local variable to __bcmgenet_tx_reclaim() to collect
>    transmitted bytes. dev->stats updates can then be moved outside the
>    while-loop. bytes_compl is also needed for future BQL support.
> 2. When bcmgenet device uses Tx checksum offload, each transmitted skb
>    gets an extra 64-byte header prepended to it. Before this header is
>    prepended to the skb, we need to save the skb "wire" length in
>    GENET_CB(skb)->bytes_sent, so that proper Tx bytes accounting can
>    be done in __bcmgenet_tx_reclaim().
> 3. skb->len covers the entire length of skb, whether it is linear or
>    fragmented. Thus, when we clean the fragments, do not increase
>    transmitted bytes.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied.
