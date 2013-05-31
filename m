From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net/3.9] ipv6: ndisc: fix ndisc_send_redirect writing to the wrong skb
Date: Fri, 31 May 2013 03:27:55 +0200
Message-ID: <5578958b49fff222740711e091c2325100f5a440.1369963643.git.mschiffer@universe-factory.net>
References: <51A66CF3.7010202@universe-factory.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51A66CF3.7010202@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since some refactoring in 5f5a011, ndisc_send_redirect called
ndisc_fill_redirect_hdr_option on the wrong skb, leading to data corruption or
in the worst case a panic when the skb_put failed.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 net/ipv6/ndisc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2712ab2..ca4ffcc 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1493,7 +1493,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	 */
 
 	if (ha)
-		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR, ha);
+		ndisc_fill_addr_option(buff, ND_OPT_TARGET_LL_ADDR, ha);
 
 	/*
 	 *	build redirect option and copy skb over to the new packet.
-- 
1.8.3
