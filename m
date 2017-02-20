From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Focusing the XDP project
Date: Mon, 20 Feb 2017 11:13:43 +0100
Message-ID: <20170220111343.76f77748@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Saeed Mahameed <saeedm@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60574 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752371AbdBTKNt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 05:13:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First thing to bring in order for the XDP project:

  RX batching is missing.

I don't want to discuss packet page-sizes or multi-port forwarding,
before we have established the most fundamental principal that all
other solution use; RX batching.

Without building in RX batching, from the beginning/now, the XDP
architecture have lost.  As adding features and capabilities, will
just lead us back to the exact same performance problems as before!


Today we already have the 64 packets NAPI budget, but we are not
taking advantage of this. For XDP as long as eBPF always return
XDP_DROP or XDP_TX, then we (falsely) experience the effect of bulking
(as code fits within the icache) and see huge perf boosts.

The initial principal of bulking/batching packets to amortize per
packet costs.  The next step is just as important: Lookup table sizes
(FIB) kills performance again. The solution is implementing a smart
table lookup scheme that prefetch hash table key-cells and afterwards
prefetch data-cells, based on the RX batch of packets.  Notice VPP
revolves around similar tricks, and why it beats DPDK, and why it
scales with 1Millon routes.

I hope I've made it very clear where the focus for XDP should be.
This involves implementing what I call RX-stages in the drivers. While
doing that we can figure out the most optimal data structure for
packet batching.
 I know Saeed is already working on RX-stages for mlx5, and I've tested
the initial version of his patch, and the results are excellent.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
