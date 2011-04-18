From: David Miller <davem@davemloft.net>
Subject: [PATCH 37/42] netfilter: nfnetlink_log: Fix set-but-unused
 variables.
Date: Sun, 17 Apr 2011 17:34:18 -0700 (PDT)
Message-ID: <20110417.173418.58426032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51096
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754175Ab1DRAex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DA29F24C08C
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'tmp_uint' is set but unused in __build_packet_message().

Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nfnetlink_log.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 985e9b7..e0ee010 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -381,7 +381,6 @@ __build_packet_message(struct nfulnl_instance *inst,
 	struct nfulnl_msg_packet_hdr pmsg;
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	__be32 tmp_uint;
 	sk_buff_data_t old_tail = inst->skb->tail;
 
 	nlh = NLMSG_PUT(inst->skb, 0, 0,
@@ -428,7 +427,6 @@ __build_packet_message(struct nfulnl_instance *inst,
 	}
 
 	if (outdev) {
-		tmp_uint = htonl(outdev->ifindex);
 #ifndef CONFIG_BRIDGE_NETFILTER
 		NLA_PUT_BE32(inst->skb, NFULA_IFINDEX_OUTDEV,
 			     htonl(outdev->ifindex));
-- 
1.7.4.3

