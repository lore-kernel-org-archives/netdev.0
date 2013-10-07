From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: [PATCH] ipv6: Fix the upper MTU limit in GRE tunnel
Date: Mon,  7 Oct 2013 18:29:35 +0100
Message-ID: <1381166975-7264-1-git-send-email-ou.ghorbel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oussama Ghorbel <ou.ghorbel@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unlike ipv4, the struct member hlen holds the length of the GRE and ipv6
headers. This length is also counted in dev->hard_header_len.
Perhaps, it's more clean to modify the hlen to count only the GRE header
without ipv6 header as the variable name suggest, but the simple way to fix
this without regression risk is simply modify the calculation of the limit
in ip6gre_tunnel_change_mtu function.
Verified in kernel version v3.11.

Signed-off-by: Oussama Ghorbel <ou.ghorbel@gmail.com>
---
 net/ipv6/ip6_gre.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 90747f1..41487ab 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1175,9 +1175,8 @@ done:
 
 static int ip6gre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct ip6_tnl *tunnel = netdev_priv(dev);
 	if (new_mtu < 68 ||
-	    new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)
+	    new_mtu > 0xFFF8 - dev->hard_header_len)
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
-- 
1.7.9.5
