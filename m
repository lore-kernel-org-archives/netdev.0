From: Lionel Elie Mamane <lionel@mamane.lu>
Subject: [PATCH] sit tunnels: propagate IPv6 transport class to IPv4 Type
 of Service
Date: Sun, 14 Aug 2011 02:04:38 +0200
Message-ID: <20110814000438.GA30127@capsaicin.mamane.lu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sit tunnels (IPv6 tunnel over IPv4) do not implement the "tos inherit"
case to copy the IPv6 transport class byte from the inner packet to
the IPv4 type of service byte in the outer packet. By contrast, ipip
tunnels and GRE tunnels do.

This patch, adapted from the similar code in net/ipv4/ipip.c and
net/ipv4/ip_gre.c, implements that.

This patch applies to 3.0.1, and has been tested on that version.


Signed-off-by: Lionel Elie Mamane <lionel@mamane.lu>

---
 net/ipv6/sit.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 1cca576..bbe2468 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -672,6 +672,10 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto tx_error;
 
+
+	if (tos == 1)
+		tos = ipv6_get_dsfield(iph6);
+
 	/* ISATAP (RFC4214) - must come before 6to4 */
 	if (dev->priv_flags & IFF_ISATAP) {
 		struct neighbour *neigh = NULL;
-- 
Lionel Mamane
