From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] gianfar: Use memset instead of cacheable_memzero
Date: Tue, 28 Apr 2009 09:14:01 -0500
Message-ID: <1240928041-10905-1-git-send-email-galak@kernel.crashing.org>
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33669 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756209AbZD1OOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 10:14:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cacheable_memzero() is completely overkill for the clearing out the FCB
block which is only 8-bytes.  The compiler should easily optimize this
with memset.  Additionally, cacheable_memzero() only exists on ppc32 and
thus breaks builds of gianfar on ppc64.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/gianfar.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index dae1437..2bb038b 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1207,7 +1207,8 @@ static int gfar_enet_open(struct net_device *dev)
 static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 {
 	struct txfcb *fcb = (struct txfcb *)skb_push(skb, GMAC_FCB_LEN);
-	cacheable_memzero(fcb, GMAC_FCB_LEN);
+
+	memset(fcb, 0, GMAC_FCB_LEN);
 
 	return fcb;
 }
-- 
1.6.0.6

