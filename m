From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [iproute2] libnetlink: reduce size of message sent to kernel
Date: Sat, 19 Nov 2016 23:50:13 +0800
Message-ID: <1479570613-3104-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:32235 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753038AbcKSPuX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 10:50:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reduce the size of message sent to kernel space. Before this
patch, for command: 'ip link show', we will sent 1056 bytes. With this
patch, we only need to send 40 bytes.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 lib/libnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 2279935..d0e19cc 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -149,7 +149,7 @@ int rtnl_wilddump_req_filter_fn(struct rtnl_handle *rth, int family, int type,
 	if (err)
 		return err;
 
-	return send(rth->fd, (void*)&req, sizeof(req), 0);
+	return send(rth->fd, (void*)&req, req.nlh.nlmsg_len, 0);
 }
 
 int rtnl_wilddump_stats_req_filter(struct rtnl_handle *rth, int fam, int type,
-- 
1.8.3.1
