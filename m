From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [PATCH] netdevice: Support DSA tagging when DSA is built as a module
Date: Fri, 12 Sep 2014 18:59:50 -0700
Message-ID: <20140913015950.26705.51106.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, davem@davemloft.net, kernel@wantstofly.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:55221 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbaIMB7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 21:59:50 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so2372466pdj.24
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 18:59:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change corrects an error seen when DSA tagging is built as a module.
Without this change it is not possible to get XDSA tagged frames as the
test for tagging is stripped by the #ifdef check.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ba72f6b..c8f3806 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1789,7 +1789,7 @@ void dev_net_set(struct net_device *dev, struct net *net)
 
 static inline bool netdev_uses_dsa(struct net_device *dev)
 {
-#ifdef CONFIG_NET_DSA
+#if IS_ENABLED(CONFIG_NET_DSA)
 	if (dev->dsa_ptr != NULL)
 		return dsa_uses_tagged_protocol(dev->dsa_ptr);
 #endif
