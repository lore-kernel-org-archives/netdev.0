From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 1/5] atl1: change tpd_avail function name
Date: Thu, 19 Jul 2007 18:45:10 -0500
Message-ID: <1184888714650-git-send-email-jacliburn@bellsouth.net>
References: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, csnook@redhat.com,
	Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf17aec.mail.bellsouth.net ([205.152.59.65]:58831 "EHLO
	imf17aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758245AbXGSXpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 19:45:17 -0400
In-Reply-To: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change tpd_avail() to atl1_tpd_avail().

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index fd1e156..79d60e1 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1422,7 +1422,7 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 		netif_wake_queue(adapter->netdev);
 }
 
-static u16 tpd_avail(struct atl1_tpd_ring *tpd_ring)
+static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
 {
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	u16 next_to_use = atomic_read(&tpd_ring->next_to_use);
@@ -1708,7 +1708,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_LOCKED;
 	}
 
-	if (tpd_avail(&adapter->tpd_ring) < count) {
+	if (atl1_tpd_avail(&adapter->tpd_ring) < count) {
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
-- 
1.5.2.2

