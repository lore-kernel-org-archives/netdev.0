From: Kangjie Lu <kangjielu@gmail.com>
Subject: [PATCH] tipc: fix an infoleak in tipc_nl_compat_link_dump
Date: Wed,  1 Jun 2016 12:34:55 -0400
Message-ID: <1464798895-26870-1-git-send-email-kjlu@gatech.edu>
Cc: ying.xue@windriver.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	taesoo@gatech.edu, csong84@gatech.edu, Kangjie Lu <kjlu@gatech.edu>
To: jon.maloy@ericsson.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

link_info.str is a char array of size 60. Memory after the NULL
byte is not initialized. Sending the whole object out can cause
a leak.

Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
---
 net/tipc/netlink_compat.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index f795b1d..115aafa 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -604,6 +604,7 @@ static int tipc_nl_compat_link_dump(struct tipc_nl_compat_msg *msg,
 
 	link_info.dest = nla_get_flag(link[TIPC_NLA_LINK_DEST]);
 	link_info.up = htonl(nla_get_flag(link[TIPC_NLA_LINK_UP]));
+	memset((void *)link_info.str, 0, TIPC_MAX_LINK_NAME);
 	strcpy(link_info.str, nla_data(link[TIPC_NLA_LINK_NAME]));
 
 	return tipc_add_tlv(msg->rep, TIPC_TLV_LINK_INFO,
-- 
2.7.4
