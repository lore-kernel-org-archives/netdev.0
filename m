From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/3] myri10ge: fix the invokation of lro_flush_all
Date: Sun, 24 May 2009 17:27:41 +0200
Message-ID: <4A19676D.5020606@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1964 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752721AbZEXP1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 11:27:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the way we check whether lro_flush_all should be called
in the myri10ge driver.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c9a9aca..d317011 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1422,6 +1422,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 {
 	struct myri10ge_rx_done *rx_done = &ss->rx_done;
 	struct myri10ge_priv *mgp = ss->mgp;
+	struct net_device *netdev = mgp->dev;
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long rx_ok;
@@ -1455,7 +1456,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 	ss->stats.rx_packets += rx_packets;
 	ss->stats.rx_bytes += rx_bytes;
 
-	if (myri10ge_lro)
+	if (netdev->features & NETIF_F_LRO)
 		lro_flush_all(&rx_done->lro_mgr);
 
 	/* restock receive rings if needed */
-- 
1.6.2.4



