From: "Geyslan G. Bem" <geyslan@gmail.com>
Subject: [PATCH] net/hsr: Fix possible leak in 'hsr_get_node_status()'
Date: Thu, 14 Nov 2013 16:12:54 -0300
Message-ID: <1384456378-29970-1-git-send-email-geyslan@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Arvid Brodin <arvid.brodin@xdin.com>,
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-kernel@vger.kernel.org (open list)
To: geyslan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:42900 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab3KNTS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 14:18:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If 'hsr_get_node_data()' returns error, going directly to 'fail' label
doesn't free the memory pointed by 'skb_out'.

Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>
---
 net/hsr/hsr_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 4e66bf6..aef8429 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -249,7 +249,7 @@ static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_info *info)
 			&hsr_node_if2_age,
 			&hsr_node_if2_seq);
 	if (res < 0)
-		goto fail;
+		goto nla_put_failure;
 
 	res = nla_put(skb_out, HSR_A_NODE_ADDR, ETH_ALEN,
 					nla_data(info->attrs[HSR_A_NODE_ADDR]));
-- 
1.8.4.2
