From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] tipc: check return value of nlmsg_new
Date: Sun, 23 Apr 2017 15:09:19 +0800
Message-ID: <1492931359-25004-1-git-send-email-bianpan2016@163.com>
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:59291 "EHLO m50-135.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1427745AbdDWHKP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 03:10:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function nlmsg_new() will return a NULL pointer if there is no enough
memory, and its return value should be checked before it is used.
However, in function tipc_nl_node_get_monitor(), the validation of the
return value of function nlmsg_new() is missed. This patch fixes the
bug.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 net/tipc/node.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 4512e83..568e48d 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -2098,6 +2098,8 @@ int tipc_nl_node_get_monitor(struct sk_buff *skb, struct genl_info *info)
 	int err;
 
 	msg.skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg.skb)
+		return -ENOMEM;
 	msg.portid = info->snd_portid;
 	msg.seq = info->snd_seq;
 
-- 
1.9.1
