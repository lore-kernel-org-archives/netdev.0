From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: decnet: dn_nsp_in: use swap macro in dn_nsp_rx_packet
Date: Sat, 28 Oct 2017 14:38:45 -0500
Message-ID: <20171028193845.GA24795@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make use of the swap macro and remove unnecessary variable tmp.
This makes the code easier to read and maintain.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/decnet/dn_nsp_in.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 7ac086d..1b212064 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -776,12 +776,8 @@ static int dn_nsp_rx_packet(struct net *net, struct sock *sk2,
 	 * Swap src & dst and look up in the normal way.
 	 */
 	if (unlikely(cb->rt_flags & DN_RT_F_RTS)) {
-		__le16 tmp = cb->dst_port;
-		cb->dst_port = cb->src_port;
-		cb->src_port = tmp;
-		tmp = cb->dst;
-		cb->dst = cb->src;
-		cb->src = tmp;
+		swap(cb->dst_port, cb->src_port);
+		swap(cb->dst, cb->src);
 	}
 
 	/*
-- 
2.7.4
