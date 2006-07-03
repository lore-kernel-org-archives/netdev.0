From: Andrey Savochkin <saw@swsoft.com>
Subject: [patch] bridge: br_dump_ifinfo index fix
Date: Mon, 3 Jul 2006 16:06:40 +0400
Message-ID: <20060703160640.A15611@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@openvz.org>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:6 "HELO castle.nmd.msu.ru")
	by vger.kernel.org with SMTP id S1751129AbWGCMGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 08:06:42 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix for inability of br_dump_ifinfo to handle non-zero start index:
loop index never increases when entered with non-zero start.
Spotted by Kirill Korotaev.

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
Cc: Kirill Korotaev <dev@openvz.org>
---
Against 2.6.17-mm6

--- ./net/bridge/br_netlink.c.vebridge-dump	Wed Jun 21 18:53:18 2006
+++ ./net/bridge/br_netlink.c	Mon Jul  3 14:31:03 2006
@@ -117,12 +117,13 @@ static int br_dump_ifinfo(struct sk_buff
 			continue;
 
 		if (idx < s_idx)
-			continue;
+			goto cont;
 
 		err = br_fill_ifinfo(skb, p, NETLINK_CB(cb->skb).pid,
 				     cb->nlh->nlmsg_seq, RTM_NEWLINK, NLM_F_MULTI);
 		if (err <= 0)
 			break;
+cont:
 		++idx;
 	}
 	read_unlock(&dev_base_lock);
