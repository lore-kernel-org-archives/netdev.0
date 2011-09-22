From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 3/4] r8169: expand received packet length indication.
Date: Thu, 22 Sep 2011 23:04:22 +0200
Message-ID: <20110922210422.GD16362@electric-eye.fr.zoreil.com>
References: <20110922210202.GA16362@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40459 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841Ab1IVVF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 17:05:27 -0400
Content-Disposition: inline
In-Reply-To: <20110922210202.GA16362@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

8168d and above allow jumbo frames beyond 8k. Bump the received
packet length check before enabling jumbo frames on these chipsets.

Frame length indication covers bits 0..13 of the first Rx descriptor
32 bits for the 8169 and 8168. I only have authoritative documentation
for the allowed use of the extra (13) bit with the 8169 and 8168c.
Realtek's drivers use the same mask for the 816x and the fast ethernet
only 810x.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 9a5965e..30bba23 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5533,7 +5533,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		} else {
 			struct sk_buff *skb;
 			dma_addr_t addr = le64_to_cpu(desc->addr);
-			int pkt_size = (status & 0x00001FFF) - 4;
+			int pkt_size = (status & 0x00003fff) - 4;
 
 			/*
 			 * The driver does not support incoming fragmented
-- 
1.7.6
