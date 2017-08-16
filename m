From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qdisc: add tracepoint qdisc:qdisc_dequeue for dequeued
 SKBs
Date: Wed, 16 Aug 2017 14:09:47 -0700 (PDT)
Message-ID: <20170816.140947.570761977406039647.davem@davemloft.net>
References: <150282426296.20350.8045788556432194444.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pstaszewski@itcare.pl
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdHPVJs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:09:48 -0400
In-Reply-To: <150282426296.20350.8045788556432194444.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 15 Aug 2017 21:11:03 +0200

> The main purpose of this tracepoint is to monitor bulk dequeue
> in the network qdisc layer, as it cannot be deducted from the
> existing qdisc stats.
> 
> The txq_state can be used for determining the reason for zero packet
> dequeues, see enum netdev_queue_state_t.
> 
> Notice all packets doesn't necessary activate this tracepoint. As
> qdiscs with flag TCQ_F_CAN_BYPASS, can directly invoke
> sch_direct_xmit() when qdisc_qlen is zero.
> 
> Remember that perf record supports filters like:
> 
>  perf record -e qdisc:qdisc_dequeue \
>   --filter 'ifindex == 4 && (packets > 1 || txq_state > 0)'
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

I'll apply this to net-next, thanks Jesper.
