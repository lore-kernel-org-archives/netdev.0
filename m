From: Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH] bridge: Fix format string for %ul
Date: Fri, 26 Aug 2016 23:10:28 -0400
Message-ID: <1472267428-810527-1-git-send-email-green@linuxhacker.ru>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

%ul would print an unsigned value and a letter l,
likely it was %lu that was meant to print the long int,
but in reality the values printed there are just regular signed
ints, so just dropping the l altogether.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 net/bridge/br_stp_bpdu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 5881fbc..15c4a9c 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -230,7 +230,7 @@ void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
 			if (net_ratelimit())
 				br_notice(p->br,
 					  "port %u config from %pM"
-					  " (message_age %ul > max_age %ul)\n",
+					  " (message_age %u > max_age %u)\n",
 					  p->port_no,
 					  eth_hdr(skb)->h_source,
 					  bpdu.message_age, bpdu.max_age);
-- 
2.7.4
