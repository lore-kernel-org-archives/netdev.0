From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] rtnetlink: return the correct error code
Date: Wed, 30 Nov 2016 16:37:34 +0800
Message-ID: <1480495054-5114-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:41149 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755255AbcK3Ihp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 03:37:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch, function ndo_dflt_fdb_dump() will always return code
from uc fdb dump. The reture code of mc fdb dump is lost.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4e60525..061415f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3165,7 +3165,7 @@ int ndo_dflt_fdb_dump(struct sk_buff *skb,
 	err = nlmsg_populate_fdb(skb, cb, dev, idx, &dev->uc);
 	if (err)
 		goto out;
-	nlmsg_populate_fdb(skb, cb, dev, idx, &dev->mc);
+	err = nlmsg_populate_fdb(skb, cb, dev, idx, &dev->mc);
 out:
 	netif_addr_unlock_bh(dev);
 	return err;
-- 
1.8.3.1
