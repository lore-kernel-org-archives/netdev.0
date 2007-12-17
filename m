From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] NET: ns83820.c remove fastcall macro
Date: Sun, 16 Dec 2007 21:06:39 -0800
Message-ID: <1197867999.3749.122.camel@brick>
References: <1197864985.3749.117.camel@brick>
	 <20071216.203029.255544808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:12249 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383AbXLQFGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 00:06:45 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1744204rvb.1
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 21:06:44 -0800 (PST)
In-Reply-To: <20071216.203029.255544808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, this is the remainder of the FASTCALL/fastcall removal
patch that is not already in your tree.
Generated against net-2.6.25.git

 drivers/net/ns83820.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 3652c6c..b42c05f 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -611,8 +611,7 @@ static inline int rx_refill(struct net_device *ndev, gfp_t gfp)
 	return i ? 0 : -ENOMEM;
 }
 
-static void rx_refill_atomic(struct net_device *ndev);
-static void fastcall rx_refill_atomic(struct net_device *ndev)
+static void rx_refill_atomic(struct net_device *ndev)
 {
 	rx_refill(ndev, GFP_ATOMIC);
 }
@@ -633,7 +632,7 @@ static inline void clear_rx_desc(struct ns83820 *dev, unsigned i)
 	build_rx_desc(dev, dev->rx_info.descs + (DESC_SIZE * i), 0, 0, CMDSTS_OWN, 0);
 }
 
-static void fastcall phy_intr(struct net_device *ndev)
+static void phy_intr(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	static const char *speeds[] = { "10", "100", "1000", "1000(?)", "1000F" };
@@ -831,7 +830,7 @@ static void ns83820_cleanup_rx(struct ns83820 *dev)
 	}
 }
 
-static void fastcall ns83820_rx_kick(struct net_device *ndev)
+static void ns83820_rx_kick(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	/*if (nr_rx_empty(dev) >= NR_RX_DESC/4)*/ {
@@ -852,7 +851,7 @@ static void fastcall ns83820_rx_kick(struct net_device *ndev)
 /* rx_irq
  *
  */
-static void fastcall rx_irq(struct net_device *ndev)
+static void rx_irq(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	struct rx_info *info = &dev->rx_info;
-- 
1.5.4.rc0.1083.gf568



