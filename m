From: djduanjiong@gmail.com
Subject: [PATCH] wimax: Use WARN(1,...) rather than printk followed by WARN_ON(1)
Date: Mon,  7 Oct 2013 17:30:38 -0700
Message-ID: <1381192238-6486-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	"David S. Miller" <davem@davemloft.net>, linux-wimax@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:53135 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756480Ab3JGQbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 12:31:08 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so7498120pbb.10
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 09:31:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/wimax/id-table.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/wimax/id-table.c b/net/wimax/id-table.c
index 72273ab..635a4d2 100644
--- a/net/wimax/id-table.c
+++ b/net/wimax/id-table.c
@@ -136,10 +136,8 @@ void wimax_id_table_release(void)
 	return;
 #endif
 	spin_lock(&wimax_id_table_lock);
-	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
-		printk(KERN_ERR "BUG: %s wimax_dev %p ifindex %d not cleared\n",
+	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node)
+		WARN(1, KERN_ERR "BUG: %s wimax_dev %p ifindex %d not cleared\n",
 		       __func__, wimax_dev, wimax_dev->net_dev->ifindex);
-		WARN_ON(1);
-	}
 	spin_unlock(&wimax_id_table_lock);
 }
-- 
1.7.7.6
