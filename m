From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v3 1/9] net: switchdev: add SET_SWITCHDEV_OPS helper
Date: Thu, 29 Jun 2017 22:08:11 +0200
Message-ID: <1498766899-30707-2-git-send-email-simon.horman@netronome.com>
References: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35438 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753477AbdF2UI6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 16:08:58 -0400
Received: by mail-qk0-f178.google.com with SMTP id 16so85802182qkg.2
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 13:08:44 -0700 (PDT)
In-Reply-To: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
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
