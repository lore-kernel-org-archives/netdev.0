From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 2/4] bql: Add tracking of inflight packets
Date: Wed, 31 Aug 2016 11:23:33 +0200
Message-ID: <20160831112333.5be19dbe@redhat.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
        <1472601634-531498-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rick.jones2@hpe.com>, <kernel-team@fb.com>,
        Achiad Shochat <achiad@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38872 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759890AbcHaJXj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 05:23:39 -0400
In-Reply-To: <1472601634-531498-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Aug 2016 17:00:32 -0700
Tom Herbert <tom@herbertland.com> wrote:

> Add two fields to netdev_queue as head_cnt and tail_cnt. head_cnt is
> incremented for every sent packet in netdev_tx_sent_queue and tail_cnt
> is incremented by the number of packets in netdev_tx_completed_queue.
> So then the number of inflight packets for a queue is simply
> queue->head_cnt - queue->tail_cnt.
> 
> Add inflight_pkts to be reported in sys-fs.

I like the idea of BQL tracking inflight packets, because we could use this
to determine _when_ qdisc bulking could be beneficial (activating xmit_more).

Idea from NetDev1.1 slides[1] page 17, and experiment with BQL
byte_queue_limits/limit_max on page 18 (which would really need a pkt
count not a byte count)

[1] http://people.netfilter.org/hawk/presentations/NetDev1.1_2016/net_performance_BoF.pdf
[2] http://people.netfilter.org/hawk/presentations/NetDev1.1_2016/links.html
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
