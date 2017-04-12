From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gso: Support frag_list splitting with
 head_frag
Date: Wed, 12 Apr 2017 13:54:02 -0400 (EDT)
Message-ID: <20170412.135402.144775618564874368.davem@davemloft.net>
References: <20170407230708.18967-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
        eric.dumazet@gmail.com, steffen.klassert@secunet.com,
        borisp@mellanox.com
To: ilant@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752057AbdDLRyJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 13:54:09 -0400
In-Reply-To: <20170407230708.18967-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <ilant@mellanox.com>
Date: Sat, 8 Apr 2017 02:07:08 +0300

> From: Ilan Tayari <ilant@mellanox.com>
> 
> A driver may use build_skb() for received packets.
> These SKBs then have a head_frag.
> 
> Since commit d7e8883cfcf4 ("net: make GRO aware of
> skb->head_frag"), GRO may build frag_list SKBs out of
> head_frag received SKBs.
> In such a case, the chained SKBs end up with a head_frag.
> 
> Commit 07b26c9454a2 ("gso: Support partial splitting at
> the frag_list pointer") adds partial segmentation of frag_list
> SKB chains into individual SKBs.
> However, this is not done if the chained SKBs have any
> linear part, because the device may not be able to DMA
> the private linear buffer.
> 
> A chained frag_list SKB with head_frag is wrongfully
> detected in this case as having a private linear part
> and thus falls back to software GSO, while in fact the
> linear part is backed by a DMA page just like any other frag.
> 
> This causes low performance when forwarding those packets
> that were built with build_skb()
> 
> Allow partial segmentation at the frag_list pointer for
> chained SKBs with head_frag.
> 
> Note that such SKBs can only be created by GRO, when applied
> to received packets with head_frag.
> Also note that this change only affects the data path that
> performs the partial segmentation at frag_list pointer, and
> not any of the other more common data paths.
> 
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>

Applied, thank you for the detailed commit message.
