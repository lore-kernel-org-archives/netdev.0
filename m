From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: orphan frags on stand-alone ptype in
 dev_queue_xmit_nit
Date: Fri, 22 Sep 2017 20:32:11 -0700 (PDT)
Message-ID: <20170922.203211.82758548639365405.davem@davemloft.net>
References: <20170922234237.43174-1-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59006 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751809AbdIWDcY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 23:32:24 -0400
In-Reply-To: <20170922234237.43174-1-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Fri, 22 Sep 2017 19:42:37 -0400

> Zerocopy skbs frags are copied when the skb is looped to a local sock.
> Commit 1080e512d44d ("net: orphan frags on receive") introduced calls
> to skb_orphan_frags to deliver_skb and __netif_receive_skb for this.
> 
> With msg_zerocopy, these skbs can also exist in the tx path and thus
> loop from dev_queue_xmit_nit. This already calls deliver_skb in its
> loop. But it does not orphan before a separate pt_prev->func().
> 
> Add the missing skb_orphan_frags_rx.
> 
> Changes
>   v1->v2: handle skb_orphan_frags_rx failure
> 
> Fixes: 1f8b977ab32d ("sock: enable MSG_ZEROCOPY")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thanks.
