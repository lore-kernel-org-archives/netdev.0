From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 1/1] tlan: Fix bugs introduced by the last tlan cleanup patch
Date: Wed,  9 Feb 2011 22:25:06 +0200
Message-ID: <1297283106-10035-1-git-send-email-sakari.ailus@iki.fi>
References: <4D52F80E.9030307@iki.fi>
Cc: error27@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:50511 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab1BIUZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 15:25:08 -0500
In-Reply-To: <4D52F80E.9030307@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix two bugs introduced by the patch "tlan: Code cleanup: checkpatch.pl is
relatively happy now." In that patch, TLAN_CSTAT_READY was considered as a
bit mask containing a single bit set while it was actually had two set
instead.

Many thanks to Dan Carpenter for finding the mistake.

Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>
---
 drivers/net/tlan.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 0678e7e..e48a808 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1522,7 +1522,8 @@ static u32 tlan_handle_tx_eof(struct net_device *dev, u16 host_int)
 		head_list = priv->tx_list + priv->tx_head;
 		head_list_phys = priv->tx_list_dma
 			+ sizeof(struct tlan_list)*priv->tx_head;
-		if (head_list->c_stat & TLAN_CSTAT_READY) {
+		if ((head_list->c_stat & TLAN_CSTAT_READY)
+		    == TLAN_CSTAT_READY) {
 			outl(head_list_phys, dev->base_addr + TLAN_CH_PARM);
 			ack |= TLAN_HC_GO;
 		} else {
@@ -1766,7 +1767,8 @@ static u32 tlan_handle_tx_eoc(struct net_device *dev, u16 host_int)
 		head_list = priv->tx_list + priv->tx_head;
 		head_list_phys = priv->tx_list_dma
 			+ sizeof(struct tlan_list)*priv->tx_head;
-		if (head_list->c_stat & TLAN_CSTAT_READY) {
+		if ((head_list->c_stat & TLAN_CSTAT_READY)
+		    == TLAN_CSTAT_READY) {
 			netif_stop_queue(dev);
 			outl(head_list_phys, dev->base_addr + TLAN_CH_PARM);
 			ack |= TLAN_HC_GO;
-- 
1.7.2.3

