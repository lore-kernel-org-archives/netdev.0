From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: l2tp: mark expected switch fall-through
Date: Tue, 17 Oct 2017 17:42:53 -0500
Message-ID: <20171017224253.GA5877@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that in this particular case I replaced the "NOBREAK" comment with
a "fall through" comment, which is what GCC is expecting to find.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).

 net/l2tp/l2tp_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 7135f46..f517942 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -406,7 +406,7 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 		if (nla_put_u16(skb, L2TP_ATTR_UDP_SPORT, ntohs(inet->inet_sport)) ||
 		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)))
 			goto nla_put_failure;
-		/* NOBREAK */
+		/* fall through  */
 	case L2TP_ENCAPTYPE_IP:
 #if IS_ENABLED(CONFIG_IPV6)
 		if (np) {
-- 
2.7.4
