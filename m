From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Fix FDDI and TR config checks in ipv4 arp and LLC.
Date: Mon, 10 May 2010 04:59:49 -0700 (PDT)
Message-ID: <20100510.045949.139122119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396Ab0EJL7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:59:41 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4EFF624C08E
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 04:59:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Need to check both CONFIG_FOO and CONFIG_FOO_MODULE

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-2.6

 net/ipv4/arp.c    |    6 +++---
 net/llc/llc_sap.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 6e74706..80769f1 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -661,13 +661,13 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 #endif
 #endif
 
-#ifdef CONFIG_FDDI
+#if defined(CONFIG_FDDI) || defined(CONFIG_FDDI_MODULE)
 	case ARPHRD_FDDI:
 		arp->ar_hrd = htons(ARPHRD_ETHER);
 		arp->ar_pro = htons(ETH_P_IP);
 		break;
 #endif
-#ifdef CONFIG_TR
+#if defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
 	case ARPHRD_IEEE802_TR:
 		arp->ar_hrd = htons(ARPHRD_IEEE802);
 		arp->ar_pro = htons(ETH_P_IP);
@@ -1051,7 +1051,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 			return -EINVAL;
 	}
 	switch (dev->type) {
-#ifdef CONFIG_FDDI
+#if defined(CONFIG_FDDI) || defined(CONFIG_FDDI_MODULE)
 	case ARPHRD_FDDI:
 		/*
 		 * According to RFC 1390, FDDI devices should accept ARP
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index a432f0e..94e7fca 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -31,7 +31,7 @@ static int llc_mac_header_len(unsigned short devtype)
 	case ARPHRD_ETHER:
 	case ARPHRD_LOOPBACK:
 		return sizeof(struct ethhdr);
-#ifdef CONFIG_TR
+#if defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
 	case ARPHRD_IEEE802_TR:
 		return sizeof(struct trh_hdr);
 #endif
-- 
1.7.0.4

