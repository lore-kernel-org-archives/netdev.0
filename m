From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] af_packet: account for VLAN when checking packet size
Date: Mon, 11 Oct 2010 15:25:22 +0200
Message-ID: <1286803522-16478-1-git-send-email-phil@nwl.cc>
References: <20101011131500.GA12342@orbit.nwl.cc>
Cc: netdev@vger.kernel.org, johann.baudy@gnu-log.net,
	eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:56646 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754312Ab0JKNZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 09:25:23 -0400
In-Reply-To: <20101011131500.GA12342@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/packet/af_packet.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9a17f28..ad37754 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -56,6 +56,7 @@
 #include <linux/in.h>
 #include <linux/inet.h>
 #include <linux/netdevice.h>
+#include <linux/if_arp.h>
 #include <linux/if_packet.h>
 #include <linux/wireless.h>
 #include <linux/kernel.h>
@@ -983,6 +984,11 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 	reserve = dev->hard_header_len;
 
+	/* allow VLAN packets when device supports them */
+	if (likely(dev->type == ARPHRD_ETHER) &&
+	    likely(!(dev->features & NETIF_F_VLAN_CHALLENGED)))
+		reserve += VLAN_HLEN;
+
 	err = -ENETDOWN;
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_put;
-- 
1.7.2.2

