From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: avoid skb_warn_bad_offload false positives on
 UFO
Date: Tue, 08 Aug 2017 21:39:49 -0700 (PDT)
Message-ID: <20170808.213949.1689446847623847043.davem@davemloft.net>
References: <20170808182255.88431-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        xiangxia.m.yue@gmail.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdHIEju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 00:39:50 -0400
In-Reply-To: <20170808182255.88431-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue,  8 Aug 2017 14:22:55 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> skb_warn_bad_offload triggers a warning when an skb enters the GSO
> stack at __skb_gso_segment that does not have CHECKSUM_PARTIAL
> checksum offload set.
> 
> Commit b2504a5dbef3 ("net: reduce skb_warn_bad_offload() noise")
> observed that SKB_GSO_DODGY producers can trigger the check and
> that passing those packets through the GSO handlers will fix it
> up. But, the software UFO handler will set ip_summed to
> CHECKSUM_NONE.
> 
> When __skb_gso_segment is called from the receive path, this
> triggers the warning again.
> 
> Make UFO set CHECKSUM_UNNECESSARY instead of CHECKSUM_NONE. On
> Tx these two are equivalent. On Rx, this better matches the
> skb state (checksum computed), as CHECKSUM_NONE here means no
> checksum computed.
> 
> See also this thread for context:
> http://patchwork.ozlabs.org/patch/799015/
> 
> Fixes: b2504a5dbef3 ("net: reduce skb_warn_bad_offload() noise")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thank you.
