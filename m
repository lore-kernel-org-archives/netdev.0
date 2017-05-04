From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] rtnetlink: NUL-terminate IFLA_PHYS_PORT_NAME string
Date: Thu,  4 May 2017 16:48:58 +0200
Message-ID: <20170504144858.1905-1-mschmidt@redhat.com>
Cc: Thomas Haller <thaller@redhat.com>, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56942 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752126AbdEDOtU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 10:49:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFLA_PHYS_PORT_NAME is a string attribute, so terminate it with \0.
Otherwise libnl3 fails to validate netlink messages with this attribute.
"ip -detail a" assumes too that the attribute is NUL-terminated when
printing it. It often was, due to padding.

I noticed this as libvirtd failing to start on a system with sfc driver
after upgrading it to Linux 4.11, i.e. when sfc added support for
phys_port_name.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c4e84c5582..69daf393cb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1056,7 +1056,7 @@ static int rtnl_phys_port_name_fill(struct sk_buff *skb, struct net_device *dev)
 		return err;
 	}
 
-	if (nla_put(skb, IFLA_PHYS_PORT_NAME, strlen(name), name))
+	if (nla_put_string(skb, IFLA_PHYS_PORT_NAME, name))
 		return -EMSGSIZE;
 
 	return 0;
-- 
2.12.2
