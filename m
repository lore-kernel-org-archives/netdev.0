From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/5] qlge: Fix sparse warnings for byte swapping in qlge_ethool.c
Date: Mon,  5 Jan 2009 14:27:28 -0800
Message-ID: <1231194452-10671-1-git-send-email-ron.mercer@qlogic.com>
References: <20090105222600.GA4232@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:42213 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbZAEW1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 17:27:36 -0500
In-Reply-To: <20090105222600.GA4232@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/qlge/qlge_ethtool.c:59:23: warning: cast to restricted type
drivers/net/qlge/qlge_ethtool.c:59:21: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_ethtool.c:59:21:    expected restricted unsigned short [usertype] irq_delay
drivers/net/qlge/qlge_ethtool.c:59:21:    got unsigned short [unsigned] [usertype] <noident>
drivers/net/qlge/qlge_ethtool.c:61:8: warning: cast to restricted type
drivers/net/qlge/qlge_ethtool.c:60:21: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_ethtool.c:60:21:    expected restricted unsigned short [usertype] pkt_delay
drivers/net/qlge/qlge_ethtool.c:60:21:    got unsigned short [unsigned] [usertype] <noident>
drivers/net/qlge/qlge_ethtool.c:82:23: warning: cast to restricted type
drivers/net/qlge/qlge_ethtool.c:82:21: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_ethtool.c:82:21:    expected restricted unsigned short [usertype] irq_delay
drivers/net/qlge/qlge_ethtool.c:82:21:    got unsigned short [unsigned] [usertype] <noident>
drivers/net/qlge/qlge_ethtool.c:84:8: warning: cast to restricted type
drivers/net/qlge/qlge_ethtool.c:83:21: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_ethtool.c:83:21:    expected restricted unsigned short [usertype] pkt_delay
drivers/net/qlge/qlge_ethtool.c:83:21:    got unsigned short [unsigned] [usertype] <noident>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_ethtool.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index eefb81b..9d922e2 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -56,9 +56,9 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 		for (i = 1; i < qdev->rss_ring_first_cq_id; i++, rx_ring++) {
 			rx_ring = &qdev->rx_ring[i];
 			cqicb = (struct cqicb *)rx_ring;
-			cqicb->irq_delay = le16_to_cpu(qdev->tx_coalesce_usecs);
+			cqicb->irq_delay = cpu_to_le16(qdev->tx_coalesce_usecs);
 			cqicb->pkt_delay =
-			    le16_to_cpu(qdev->tx_max_coalesced_frames);
+			    cpu_to_le16(qdev->tx_max_coalesced_frames);
 			cqicb->flags = FLAGS_LI;
 			status = ql_write_cfg(qdev, cqicb, sizeof(cqicb),
 						CFG_LCQ, rx_ring->cq_id);
@@ -79,9 +79,9 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 		     i++) {
 			rx_ring = &qdev->rx_ring[i];
 			cqicb = (struct cqicb *)rx_ring;
-			cqicb->irq_delay = le16_to_cpu(qdev->rx_coalesce_usecs);
+			cqicb->irq_delay = cpu_to_le16(qdev->rx_coalesce_usecs);
 			cqicb->pkt_delay =
-			    le16_to_cpu(qdev->rx_max_coalesced_frames);
+			    cpu_to_le16(qdev->rx_max_coalesced_frames);
 			cqicb->flags = FLAGS_LI;
 			status = ql_write_cfg(qdev, cqicb, sizeof(cqicb),
 						CFG_LCQ, rx_ring->cq_id);
-- 
1.6.0

