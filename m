From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 3/3] korina: count RX DMA OVR as rx_fifo_error
Date: Sun, 30 May 2010 01:23:36 +0200
Message-ID: <20100529232345.CA3124CD45@orbit.nwl.cc>
References: <1275175416-21267-1-git-send-email-phil@nwl.cc>
 <1275175416-21267-2-git-send-email-phil@nwl.cc>
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:45301 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754598Ab0E2XXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 May 2010 19:23:46 -0400
In-Reply-To: <1275175416-21267-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This way, RX DMA overruns (actually being caused by overrun of the
512byte input FIFO) show up in ifconfig output. The rx_fifo_errors
counter is unused otherwise.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/net/korina.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 3e9b6b7..c7a9bef 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -376,7 +376,7 @@ static int korina_rx(struct net_device *dev, int limit)
 		if (devcs & ETH_RX_LE)
 			dev->stats.rx_length_errors++;
 		if (devcs & ETH_RX_OVR)
-			dev->stats.rx_over_errors++;
+			dev->stats.rx_fifo_errors++;
 		if (devcs & ETH_RX_CV)
 			dev->stats.rx_frame_errors++;
 		if (devcs & ETH_RX_CES)
-- 
1.6.4.4

