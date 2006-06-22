From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 26/32] [TIPC] Fixed memory leak in tipc_link_send() when destination is unreachable
Date: Thu, 22 Jun 2006 15:59:39 +0200
Message-ID: <11509847873708-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:39574 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030638AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/link.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index ba7d3f1..ff40c91 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1135,9 +1135,13 @@ int tipc_link_send(struct sk_buff *buf, 
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[selector & 1];
-		dbg("tipc_link_send: found link %x for dest %x\n", l_ptr, dest);
 		if (l_ptr) {
+			dbg("tipc_link_send: found link %x for dest %x\n", l_ptr, dest);
 			res = tipc_link_send_buf(l_ptr, buf);
+		} else {
+			dbg("Attempt to send msg to unreachable node:\n");
+			msg_dbg(buf_msg(buf),">>>");
+			buf_discard(buf);
 		}
 		tipc_node_unlock(n_ptr);
 	} else {
-- 
1.4.0

