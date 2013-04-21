From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/3] net: fix netdev features shift for features bit > 31
Date: Sun, 21 Apr 2013 12:09:33 +0200
Message-ID: <1366538974-4589-2-git-send-email-kaber@trash.net>
References: <1366538974-4589-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62313 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787Ab3DUKJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 06:09:44 -0400
In-Reply-To: <1366538974-4589-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c: In function 'qlcnic_set_netdev_features':
>> drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:967:7: warning: large integer implicitly truncated to unsigned type [-Woverflow]

This should be fixed by explicitly using 1ULL for the shifted value.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netdev_features.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index cbaa027..f4d20f5 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -71,7 +71,7 @@ enum {
 };
 
 /* copy'n'paste compression ;) */
-#define __NETIF_F_BIT(bit)	((netdev_features_t)1 << (bit))
+#define __NETIF_F_BIT(bit)	((netdev_features_t)1ULL << (bit))
 #define __NETIF_F(name)		__NETIF_F_BIT(NETIF_F_##name##_BIT)
 
 #define NETIF_F_FCOE_CRC	__NETIF_F(FCOE_CRC)
-- 
1.8.1.4
