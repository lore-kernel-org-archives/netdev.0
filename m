From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] rtnl: fix the loop index update error in rtnl_dump_ifinfo()
Date: Sat, 19 Nov 2016 23:28:32 +0800
Message-ID: <1479569312-15224-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:4390 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752975AbcKSP2u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 10:28:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the link is filtered out, loop index should also be updated. If not,
loop index will not be correct.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index db313ec..f4b9350 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1606,7 +1606,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 		head = &net->dev_index_head[h];
 		hlist_for_each_entry(dev, head, index_hlist) {
 			if (link_dump_filtered(dev, master_idx, kind_ops))
-				continue;
+				goto cont;
 			if (idx < s_idx)
 				goto cont;
 			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
-- 
1.8.3.1
