From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 1/9] net: switchdev: add SET_SWITCHDEV_OPS helper
Date: Wed, 28 Jun 2017 01:21:41 +0200
Message-ID: <1498605709-22574-2-git-send-email-simon.horman@netronome.com>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33502 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753980AbdF0XWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:22:13 -0400
Received: by mail-qk0-f182.google.com with SMTP id r62so38340509qkf.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:22:12 -0700 (PDT)
In-Reply-To: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper to allow switchdev ops to be set if NET_SWITCHDEV is configured
and do nothing otherwise. This allows for slightly cleaner code which
uses switchdev but does not select NET_SWITCHDEV.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/switchdev.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index c784a6ac6ef1..8ae9e3b6392e 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -217,6 +217,8 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 
 bool switchdev_port_same_parent_id(struct net_device *a,
 				   struct net_device *b);
+
+#define SWITCHDEV_SET_OPS(netdev, ops) ((netdev)->switchdev_ops = (ops))
 #else
 
 static inline void switchdev_deferred_process(void)
@@ -322,6 +324,8 @@ static inline bool switchdev_port_same_parent_id(struct net_device *a,
 	return false;
 }
 
+#define SWITCHDEV_SET_OPS(netdev, ops) do {} while (0)
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
-- 
2.1.4
