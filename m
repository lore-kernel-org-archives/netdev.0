From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 24/24] net: rbridge: replace net_port rx_handler
Date: Wed, 24 Sep 2014 17:52:20 +0200
Message-ID: <1411573940-14079-25-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:45186 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbaIXQDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:10 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace classic rx_handler in bridge by the new rbr_handle_frame in
order to provide trill support

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/br_if.c      | 4 ++++
 net/bridge/br_private.h | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 078d336..7e6c6a0 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -480,7 +480,11 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err4;
 
+#ifdef CONFIG_TRILL
+	err = netdev_rx_handler_register(dev, rbr_handle_frame, p);
+#else
 	err = netdev_rx_handler_register(dev, br_handle_frame, p);
+#endif
 	if (err)
 		goto err5;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 152545e..31bccf8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -876,4 +876,8 @@ static inline int br_sysfs_addbr(struct net_device *dev) { return 0; }
 static inline void br_sysfs_delbr(struct net_device *dev) { return; }
 #endif /* CONFIG_SYSFS */
 
+#ifdef CONFIG_TRILL
+/* rbridge/rbr.c */
+extern rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb);
+#endif /* CONFIG_TRILL */
 #endif
-- 
1.9.1
