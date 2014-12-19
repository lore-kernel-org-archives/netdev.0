From: roy.qing.li@gmail.com
Subject: [PATCH net-next] netdevice: optimise netdev_intersect_features slightly
Date: Fri, 19 Dec 2014 13:21:27 +0800
Message-ID: <1418966487-23347-1-git-send-email-roy.qing.li@gmail.com>
Cc: mkubecek@suse.cz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:42457 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbaLSFVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 00:21:32 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so457496pad.31
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 21:21:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Since f1 and f2 always have NETIF_F_GEN_CSUM when doing Bitwise OR assignment,
it is unnecessory to clear NETIF_F_GEN_CSUM from the added data

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Cc: Michal Kubecek <mkubecek@suse.cz>
---
 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c31f74d..b8facf9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3542,9 +3542,9 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
 							  netdev_features_t f2)
 {
 	if (f1 & NETIF_F_GEN_CSUM)
-		f1 |= (NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+		f1 |= NETIF_F_ALL_CSUM;
 	if (f2 & NETIF_F_GEN_CSUM)
-		f2 |= (NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
+		f2 |= NETIF_F_ALL_CSUM;
 	f1 &= f2;
 	if (f1 & NETIF_F_GEN_CSUM)
 		f1 &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
-- 
2.1.0
