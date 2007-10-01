From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 2/9] fs_enet: Fix build breakage.
Date: Mon, 1 Oct 2007 14:20:47 -0500
Message-ID: <20071001192047.GA28429@loki.buserror.net>
References: <20071001192017.GA28410@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:47706 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075AbXJATVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 15:21:25 -0400
Content-Disposition: inline
In-Reply-To: <20071001192017.GA28410@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 4fa57c9ea9f36f9ca852f3a88ca5d2f1aebbc960
("Make NAPI polling independent of struct net_device objects.")
introduced some build breakage in the napi rx function.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/fs_enet-main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 2a1b150..a15345b 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -73,8 +73,8 @@ static void fs_set_multicast_list(struct net_device *dev)
 /* NAPI receive function */
 static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 {
-	struct fs_enet_private *fep = container_of(napi, struct fec_enet_private, napi);
-	struct net_device *dev = fep->dev;
+	struct fs_enet_private *fep = container_of(napi, struct fs_enet_private, napi);
+	struct net_device *dev = to_net_dev(fep->dev);
 	const struct fs_platform_info *fpi = fep->fpi;
 	cbd_t *bdp;
 	struct sk_buff *skb, *skbn, *skbt;
-- 
1.5.3.2

