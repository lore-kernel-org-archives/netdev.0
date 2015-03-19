From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [PATCH 1/2] af_packet: make tpacket_rcv to not set status value before run_filter
Date: Thu, 19 Mar 2015 11:01:41 +0300
Message-ID: <1426752102-12786-1-git-send-email-al.drozdov@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Willem de Bruijn <willemb@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is just an optimization. We don't need the value of status variable
if the packet is filtered.

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
---
 net/packet/af_packet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f8db706..6ecf8dd 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1910,14 +1910,15 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		status |= TP_STATUS_CSUMNOTREADY;
-
 	snaplen = skb->len;
 
 	res = run_filter(skb, sk, snaplen);
 	if (!res)
 		goto drop_n_restore;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		status |= TP_STATUS_CSUMNOTREADY;
+
 	if (snaplen > res)
 		snaplen = res;
 
-- 
1.9.1
