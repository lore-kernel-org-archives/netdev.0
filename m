From: John Crispin <john@phrozen.org>
Subject: [RFC 0/2] net-next: hw flow offloading
Date: Fri, 21 Jul 2017 17:20:33 +0200
Message-ID: <20170721152035.6645-1-john@phrozen.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I managed to bring up the flow offloading on latest MedieTek silicon.

When enabling HW flow offloading, the traffic coming in on either of the
GMACs is first sent to the PPE for processing. Any traffic not offloaded
at this point will then be forwarded to the normal RX DMA ring for SW path
processing. In this case the PPE will send additional data inside RXD4
that is later required by the upper layers to populate the flow offloading
engines HW tables properly.

This series is a RFC as i am not sure how to best propagate the additional
info from the RX DMA descriptor. The driver is still using NF hooks and
I plan to rebase it and send it upstream once the flow table offloading
patches that folks are working on are upstream.

I am right now trying to get rid of the remaning hacks in the code and
wanted to know if this series would be a feasible solution.

	John

John Crispin (2):
  net-next: add a dma_desc element to struct skb_shared_info
  net-next: mediatek: populate the shared

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 ++++
 include/linux/skbuff.h                      | 1 +
 2 files changed, 5 insertions(+)

-- 
2.11.0
