From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 6/6] tilepro: use to_delayed_work
Date: Fri,  1 Jan 2016 23:48:57 +0800
Message-ID: <de283954b255f02130170f4e362d92ef95a7cf79.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@ezchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-138.163.com ([123.125.50.138]:56261 "EHLO m50-138.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055AbcAAPtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jan 2016 10:49:52 -0500
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/ethernet/tile/tilepro.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 6f0a449..298e059 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -1349,8 +1349,7 @@ static int tile_net_open_inner(struct net_device *dev)
  */
 static void tile_net_open_retry(struct work_struct *w)
 {
-	struct delayed_work *dw =
-		container_of(w, struct delayed_work, work);
+	struct delayed_work *dw = to_delayed_work(w);
 
 	struct tile_net_priv *priv =
 		container_of(dw, struct tile_net_priv, retry_work);
-- 
2.5.0
