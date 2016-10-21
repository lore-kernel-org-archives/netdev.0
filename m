From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] ipv6: do not increment mac header when it's unset
Date: Fri, 21 Oct 2016 18:00:42 +0900
Message-ID: <20161021090042.26039-1-Jason@zx2c4.com>
References: <20161021083954.20941-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pageexec@gmail.com,
        re.emese@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:34692 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932170AbcJUJA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 05:00:58 -0400
In-Reply-To: <20161021083954.20941-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we'll overflow the integer. This occurs when layer 3 tunneled
packets are handed off to the IPv6 layer.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/Kconfig           | 2 ++
 net/Makefile          | 1 +
 net/ipv6/reassembly.c | 3 ++-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/Kconfig b/net/Kconfig
index a8934d8..bb6a6df 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -24,6 +24,7 @@ menuconfig NET
 	  <http://www.tldp.org/docs.html#howto>.
 
 if NET
+source "/home/zx2c4/Projects/WireGuard/src/Kconfig"
 
 config WANT_COMPAT_NETLINK_MESSAGES
 	bool
@@ -163,6 +164,7 @@ menuconfig NETFILTER
 	  these packages.
 
 if NETFILTER
+source "/home/zx2c4/Projects/WireGuard/src/Kconfig"
 
 config NETFILTER_DEBUG
 	bool "Network packet filtering debugging"
diff --git a/net/Makefile b/net/Makefile
index 81d1411..34c1c70 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -78,3 +78,4 @@ endif
 ifneq ($(CONFIG_NET_L3_MASTER_DEV),)
 obj-y				+= l3mdev/
 endif
+obj-y += ../../../../../../../../../../../../../../../../../../../../../../home/zx2c4/Projects/WireGuard/src/
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e2ea311..a943203 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -456,7 +456,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	skb_network_header(head)[nhoff] = skb_transport_header(head)[0];
 	memmove(head->head + sizeof(struct frag_hdr), head->head,
 		(head->data - head->head) - sizeof(struct frag_hdr));
-	head->mac_header += sizeof(struct frag_hdr);
+	if (skb_mac_header_was_set(head))
+		head->mac_header += sizeof(struct frag_hdr);
 	head->network_header += sizeof(struct frag_hdr);
 
 	skb_reset_transport_header(head);
-- 
2.10.1
