From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] net: properly flush delay-freed skbs
Date: Wed, 23 Nov 2016 19:11:58 +0100
Message-ID: <20161123191158.7428780a@redhat.com>
References: <1479919496.8455.509.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAKgT0UerbiZ8cWk3hkVO2SckxBgiG3zsLn_P05jM=-Cr6B3qAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59908 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755538AbcKWSMD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 13:12:03 -0500
In-Reply-To: <CAKgT0UerbiZ8cWk3hkVO2SckxBgiG3zsLn_P05jM=-Cr6B3qAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Nov 2016 09:12:50 -0800
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Wed, Nov 23, 2016 at 8:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Typical NAPI drivers use napi_consume_skb(skb) at TX completion time.
> > This put skb in a percpu special queue, napi_alloc_cache, to get bulk
> > frees.
> >
> > It turns out the queue is not flushed and hits the NAPI_SKB_CACHE_SIZE
> > limit quite often, with skbs that were queued hundreds of usec earlier.
> > I measured this can take ~6000 nsec to perform one flush.
> >
> > __kfree_skb_flush() can be called from two points right now :
> >
> > 1) From net_tx_action(), but only for skbs that were queued to
> > sd->completion_queue.
> >  
> >  -> Irrelevant for NAPI drivers in normal operation.  
> >
> > 2) From net_rx_action(), but only under high stress or if RPS/RFS has a
> > pending action.
> >
> > This patch changes net_rx_action() to perform the flush in all cases and
> > after more urgent operations happened (like kicking remote CPUS for
> > RPS/RFS).
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> > Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> > ---  
> 
> Yeah, we didn't intent the data to be sitting around that long.  The
> change looks good to me.
> 
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

Also looks good to me! Thanks for catching this.

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
