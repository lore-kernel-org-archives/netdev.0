From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net: properly flush delay-freed skbs
Date: Wed, 23 Nov 2016 09:12:50 -0800
Message-ID: <CAKgT0UerbiZ8cWk3hkVO2SckxBgiG3zsLn_P05jM=-Cr6B3qAg@mail.gmail.com>
References: <1479919496.8455.509.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33902 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756124AbcKWRMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 12:12:54 -0500
Received: by mail-io0-f169.google.com with SMTP id c21so31984015ioj.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 09:12:54 -0800 (PST)
In-Reply-To: <1479919496.8455.509.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 8:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Typical NAPI drivers use napi_consume_skb(skb) at TX completion time.
> This put skb in a percpu special queue, napi_alloc_cache, to get bulk
> frees.
>
> It turns out the queue is not flushed and hits the NAPI_SKB_CACHE_SIZE
> limit quite often, with skbs that were queued hundreds of usec earlier.
> I measured this can take ~6000 nsec to perform one flush.
>
> __kfree_skb_flush() can be called from two points right now :
>
> 1) From net_tx_action(), but only for skbs that were queued to
> sd->completion_queue.
>
>  -> Irrelevant for NAPI drivers in normal operation.
>
> 2) From net_rx_action(), but only under high stress or if RPS/RFS has a
> pending action.
>
> This patch changes net_rx_action() to perform the flush in all cases and
> after more urgent operations happened (like kicking remote CPUS for
> RPS/RFS).
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

Yeah, we didn't intent the data to be sitting around that long.  The
change looks good to me.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
