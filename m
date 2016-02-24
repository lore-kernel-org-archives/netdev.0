From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] tipc: fix null deref crash in compat config path
Date: Wed, 24 Feb 2016 17:20:17 +0100
Message-ID: <1456330817-21347-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:35783 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751830AbcBXQYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 11:24:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

msg.dst_sk needs to be set up with a valid socket because some callbacks
later derive the netns from it.

Fixes: 263ea09084d172d ("Revert "genl: Add genlmsg_new_unicast() for unicast message allocation")
Reported-by: Jon Maloy <maloy@donjonn.com>
Bisected-by: Jon Maloy <maloy@donjonn.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/netlink_compat.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index de66d8f..d7d050f 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -1105,6 +1105,7 @@ static int tipc_nl_compat_recv(struct sk_buff *skb, struct genl_info *info)
 	msg.req = nlmsg_data(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN;
 	msg.cmd = req_userhdr->cmd;
 	msg.net = genl_info_net(info);
+	msg.dst_sk = skb->sk;
 
 	if ((msg.cmd & 0xC000) && (!netlink_net_capable(skb, CAP_NET_ADMIN))) {
 		msg.rep = tipc_get_err_tlv(TIPC_CFG_NOT_NET_ADMIN);
-- 
2.4.10
