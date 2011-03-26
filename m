From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] net: use CHECKSUM_NONE instead of magic number
Date: Sat, 26 Mar 2011 12:10:30 -0300
Message-ID: <1301152230-4897-1-git-send-email-cesarb@cesarb.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tristram Ha <Tristram.Ha@micrel.com>,
	linux-kernel@vger.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-02.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 26 Mar 2011 15:10:36 -0000
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two places in the kernel were doing skb->ip_summed = 0.

Change both to skb->ip_summed = CHECKSUM_NONE, which is more readable.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/ksz884x.c |    2 +-
 net/ipv6/ip6mr.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 540a8dc..7f7d570 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -4898,7 +4898,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
 				goto unlock;
 			}
 			skb_copy_and_csum_dev(org_skb, skb->data);
-			org_skb->ip_summed = 0;
+			org_skb->ip_summed = CHECKSUM_NONE;
 			skb->len = org_skb->len;
 			copy_old_skb(org_skb, skb);
 		}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7ff0343..29e4859 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -663,7 +663,7 @@ static int pim6_rcv(struct sk_buff *skb)
 	skb_pull(skb, (u8 *)encap - skb->data);
 	skb_reset_network_header(skb);
 	skb->protocol = htons(ETH_P_IPV6);
-	skb->ip_summed = 0;
+	skb->ip_summed = CHECKSUM_NONE;
 	skb->pkt_type = PACKET_HOST;
 
 	skb_tunnel_rx(skb, reg_dev);
-- 
1.7.4
