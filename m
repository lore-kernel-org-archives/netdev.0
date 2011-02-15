From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 1/5] bridge: Fix IPv6 multicast snooping by storing correct protocol type
Date: Wed, 16 Feb 2011 00:19:17 +0100
Message-ID: <1297811961-19249-2-git-send-email-linus.luessing@web.de>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The protocol type for IPv6 entries in the hash table for multicast
bridge snooping is falsely set to ETH_P_IP, marking it as an IPv4
address, instead of setting it to ETH_P_IPV6, which results in negative
look-ups in the hash table later.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index f701a21..135d929 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -785,7 +785,7 @@ static int br_ip6_multicast_add_group(struct net_br=
idge *br,
 		return 0;
=20
 	ipv6_addr_copy(&br_group.u.ip6, group);
-	br_group.proto =3D htons(ETH_P_IP);
+	br_group.proto =3D htons(ETH_P_IPV6);
=20
 	return br_multicast_add_group(br, port, &br_group);
 }
--=20
1.7.2.3
