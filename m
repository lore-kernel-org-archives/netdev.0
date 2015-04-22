From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] vxlan: remove the unnecessary codes
Date: Wed, 22 Apr 2015 15:49:10 +0800
Message-ID: <1429688950-10450-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38328 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964979AbbDVHtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:49:11 -0400
Received: from localhost (lirq-optiplex-780.corp.ad.wrs.com [128.224.162.139])
	by mail.windriver.com (8.14.9/8.14.9) with ESMTP id t3M7nA8J029308
	for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 00:49:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The return value of vxlan_fdb_replace always is greater than or equal to 0

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/vxlan.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 154116a..27a5f95 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -730,12 +730,8 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			/* Only change unicasts */
 			if (!(is_multicast_ether_addr(f->eth_addr) ||
 			     is_zero_ether_addr(f->eth_addr))) {
-				int rc = vxlan_fdb_replace(f, ip, port, vni,
+				notify |= vxlan_fdb_replace(f, ip, port, vni,
 							   ifindex);
-
-				if (rc < 0)
-					return rc;
-				notify |= rc;
 			} else
 				return -EOPNOTSUPP;
 		}
-- 
2.1.0
