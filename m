From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: [PATCH 3/5] tipc: set skb->protocol in eth_media packet transmission
Date: Wed,  3 Apr 2013 14:43:28 +0200
Message-ID: <1364993010-15515-4-git-send-email-kaber@trash.net>
References: <1364993010-15515-1-git-send-email-kaber@trash.net>
Cc: allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364993010-15515-1-git-send-email-kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The skb->protocol field is used by packet classifiers and for AF_PACKET
cooked format, TIPC needs to set it properly.

Fixes packet classification and ethertype of 0x0000 in cooked captures:

Out 20:c9:d0:43:12:d9 ethertype Unknown (0x0000), length 56:
	0x0000:  5b50 0028 0000 30d4 0100 1000 0100 1001  [P.(..0.........
	0x0010:  0000 03e8 0000 0001 20c9 d043 12d9 0000  ...........C....
	0x0020:  0000 0000 0000 0000                      ........

Signed-off-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
---
 net/tipc/eth_media.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 0648819..120a676 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -111,6 +111,7 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 
 	skb_reset_network_header(clone);
 	clone->dev = dev;
+	clone->protocol = htons(ETH_P_TIPC);
 	dev_hard_header(clone, dev, ETH_P_TIPC, dest->value,
 			dev->dev_addr, clone->len);
 	dev_queue_xmit(clone);
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
