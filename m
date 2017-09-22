From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net: orphan frags on stand-alone ptype in
 dev_queue_xmit_nit
Date: Fri, 22 Sep 2017 16:50:06 -0700
Message-ID: <1506124206.29839.178.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170922234237.43174-1-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33270 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751763AbdIVXuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 19:50:08 -0400
Received: by mail-pg0-f67.google.com with SMTP id i130so1446484pgc.0
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 16:50:08 -0700 (PDT)
In-Reply-To: <20170922234237.43174-1-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-22 at 19:42 -0400, Willem de Bruijn wrote:
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
> ---
>  net/core/dev.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

Reviewed-by: Eric Dumazet <edumazet@google.com>
