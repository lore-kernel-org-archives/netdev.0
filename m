From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: rewrite bcmgenet_rx_refill()
Date: Thu, 12 Mar 2015 23:03:48 -0400 (EDT)
Message-ID: <20150312.230348.1911227825204957840.davem@davemloft.net>
References: <20150312224800.AE7A7220365@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408AbbCMDDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 23:03:50 -0400
In-Reply-To: <20150312224800.AE7A7220365@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Thu, 12 Mar 2015 15:48:00 -0700 (PDT)

> Currently, bcmgenet_desc_rx() calls bcmgenet_rx_refill() at the end of
> Rx packet processing loop, after the current Rx packet has already been
> passed to napi_gro_receive(). However, bcmgenet_rx_refill() might fail
> to allocate a new Rx skb, thus leaving a hole on the Rx queue where no
> valid Rx buffer exists.
> 
> To eliminate this situation:
> 1. Rewrite bcmgenet_rx_refill() to retain the current Rx skb on the Rx
>    queue if a new replacement Rx skb can't be allocated and DMA-mapped.
>    In this case, the data on the current Rx skb is effectively dropped.
> 2. Modify bcmgenet_desc_rx() to call bcmgenet_rx_refill() at the top of
>    Rx packet processing loop, so that the new replacement Rx skb is
>    already in place before the current Rx skb is processed.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

I'll apply this after Florian reports back about his testing.
