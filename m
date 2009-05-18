From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: bnx2_tx_int() optimizations
Date: Sun, 17 May 2009 20:48:10 -0700 (PDT)
Message-ID: <20090517.204810.15778716.davem@davemloft.net>
References: <4A0A6D22.5060007@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754456AbZERDsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 23:48:13 -0400
In-Reply-To: <4A0A6D22.5060007@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 13 May 2009 08:48:02 +0200

> When using bnx2 in a high transmit load, bnx2_tx_int() cost is pretty high.
 ...
> This patch :
> 
> 1) avoids calling bnx2_get_hw_tx_cons(bnapi) too many times.
> 
> 2) makes bnx2_start_xmit() cache is_gso & nr_frags into sw_tx_bd descriptor.
>    This uses a litle bit more ram (256 longs per device on x86), but helps a lot.
> 
> 3) uses a prefetch(&skb->end) to speedup dev_kfree_skb(), bringing
>   cache line that will be needed in skb_release_data()
> 
> 
> result is 5 % bandwidth increase in benchmarks, involving UDP or TCP receive
>  & transmits, when a cpu is dedicated to ksoftirqd for bnx2.
> 
> bnx2_tx_int going from 3.33 % cpu to 0.5 % cpu in oprofile
> 
> Note : skb_dma_unmap() still very expensive but this is for another patch, 
> not related to bnx2 (2.9 % of cpu, while it does nothing on x86_32)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Looks great, I've applied this, thanks Eric!
