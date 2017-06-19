From: John Crispin <john@phrozen.org>
Subject: [PATCH 0/4] net-next: mediatek: various performance improvements
Date: Mon, 19 Jun 2017 15:37:02 +0200
Message-ID: <20170619133706.3415-1-john@phrozen.org>
Cc: linux-mediatek@lists.infradead.org, netdev@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Sean Wang <sean.wang@mediatek.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:57330 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751082AbdFSNhY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 09:37:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During development we mainly ran testing using iperf doing 1500 byte
tcp frames. It was pointed out recently, that the driver does not perform
very well when using 512 byte udp frames. The biggest problem was that
RPS was not working as no rx queue was being set. fixing this more than
doubled the throughput. Additionally the IRQ mask register is now locked
independently for RX and TX. RX IRQ aggregation is also added. With all
these patches applied we can almost triple the throughput.

While at it we also add PHY status change reporting for GMACs connecting
directly to a PHY.

John Crispin (4):
  net-next: mediatek: print phy status changes for non DSA GMACs
  net-next: mediatek: add RX IRQ delay support
  net-next: mediatek: split IRQ register locking into TX and RX
  net-next: mediatek: set the rx_queue to 0

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 87 +++++++++++++++++++----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 18 ++++--
 2 files changed, 71 insertions(+), 34 deletions(-)

-- 
2.11.0
