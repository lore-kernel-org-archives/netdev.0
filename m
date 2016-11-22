From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net] rtnetlink: fix the wrong minimal dump size getting from rtnl_calcit()
Date: Tue, 22 Nov 2016 14:14:28 +0800
Message-ID: <1479795268-11801-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: roopa@cumulusnetworks.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:61849 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751021AbcKVGOz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 01:14:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RT netlink, calcit() function should return the minimal size for
netlink dump message. This will make sure that dump message for every
network device can be stored.

Currently, rtnl_calcit() function doesn't account the size of header of
netlink message, this patch will fix it.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f4b9350..09e115b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2734,7 +2734,7 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 						           ext_filter_mask));
 	}
 
-	return min_ifinfo_dump_size;
+	return nlmsg_total_size(min_ifinfo_dump_size);
 }
 
 static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
-- 
1.8.3.1
