From: Joe Perches <joe@perches.com>
Subject: [PATCH] net: af_packet: Don't initialize vnet_hdr
Date: Thu, 12 May 2011 13:36:10 -0700
Message-ID: <18a010357eb63dfd50751c5eb529f6261cf90ecd.1305232529.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Save a memset, initialize only the portion necessary.

packet_snd either gets this structure completely from
memcpy_fromiovec or uses only the hdr_len set to 0,
so don't always initialize the structure to 0.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/packet/af_packet.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 549527b..ac88df9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1123,7 +1123,7 @@ static int packet_snd(struct socket *sock,
 	__be16 proto;
 	unsigned char *addr;
 	int ifindex, err, reserve = 0;
-	struct virtio_net_hdr vnet_hdr = { 0 };
+	struct virtio_net_hdr vnet_hdr;
 	int offset = 0;
 	int vnet_hdr_len;
 	struct packet_sock *po = pkt_sk(sk);
@@ -1206,7 +1206,9 @@ static int packet_snd(struct socket *sock,
 				goto out_unlock;
 
 		}
-	}
+	} else
+		vnet_hdr.hdr_len = 0;
+
 
 	err = -EMSGSIZE;
 	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN))
-- 
1.7.5.rc3.dirty
