From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] tun: don't set NETIF_F_FRAGLIST
Date: Wed,  5 Nov 2008 12:36:27 +0000
Message-ID: <1225888587-1387-1-git-send-email-markmc@redhat.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Max Krasnyansky <maxk@qualcomm.com>,
	Mark McLoughlin <markmc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail04.svc.cra.dublin.eircom.net ([159.134.118.20]:37062 "HELO
	mail04.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754911AbYKEMh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 07:37:28 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't handle skb_shared_info->frag_list, so we shouldn't
be setting the NETIF_F_FRAGLIST flag.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/tun.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 33b6d1b..7f9084c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -844,11 +844,11 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 
 	old_features = dev->features;
 	/* Unset features, set them as we chew on the arg. */
-	features = (old_features & ~(NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST
+	features = (old_features & ~(NETIF_F_HW_CSUM|NETIF_F_SG
 				    |NETIF_F_TSO_ECN|NETIF_F_TSO|NETIF_F_TSO6));
 
 	if (arg & TUN_F_CSUM) {
-		features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		features |= NETIF_F_HW_CSUM|NETIF_F_SG;
 		arg &= ~TUN_F_CSUM;
 
 		if (arg & (TUN_F_TSO4|TUN_F_TSO6)) {
-- 
1.5.4.3

