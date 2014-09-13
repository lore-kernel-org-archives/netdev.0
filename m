From: alexander.duyck@gmail.com
Subject: [PATCH v2] netdevice: Support DSA tagging when DSA is built as a
 module
Date: Fri, 12 Sep 2014 23:12:46 -0700
Message-ID: <20140913061142.28675.38168.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, davem@davemloft.net, kernel@wantstofly.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36985 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbaIMGMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 02:12:44 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2672922pdj.22
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 23:12:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects an error seen when DSA tagging is built as a module.
Without this change it is not possible to get XDSA tagged frames as the
test for tagging is stripped by the #ifdef check.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---

v2: Just working out some kinks in my stgit config so that this patch is
    attributed to my intel.com address instead of my gmail.com address.

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
