From: igorm@etf.rs
Subject: [PATCH net-next] ipv4: arp: Cleanup in arp.c
Date: Mon,  5 Dec 2011 13:25:57 +0100
Message-ID: <1323087957-26429-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:41228 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932142Ab1LEM0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 07:26:03 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Use "IS_ENABLED(CONFIG_FOO)" macro instead of
"defined(CONFIG_FOO) || defined(CONFIG_FOO_MODULE)"

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/ipv4/arp.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ff324eb..381a087 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -277,9 +277,9 @@ static int arp_constructor(struct neighbour *neigh)
 		default:
 			break;
 		case ARPHRD_ROSE:
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+#if IS_ENABLED(CONFIG_AX25)
 		case ARPHRD_AX25:
-#if defined(CONFIG_NETROM) || defined(CONFIG_NETROM_MODULE)
+#if IS_ENABLED(CONFIG_NETROM)
 		case ARPHRD_NETROM:
 #endif
 			neigh->ops = &arp_broken_ops;
@@ -629,13 +629,13 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 		arp->ar_pro = htons(ETH_P_IP);
 		break;
 
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+#if IS_ENABLED(CONFIG_AX25)
 	case ARPHRD_AX25:
 		arp->ar_hrd = htons(ARPHRD_AX25);
 		arp->ar_pro = htons(AX25_P_IP);
 		break;
 
-#if defined(CONFIG_NETROM) || defined(CONFIG_NETROM_MODULE)
+#if IS_ENABLED(CONFIG_NETROM)
 	case ARPHRD_NETROM:
 		arp->ar_hrd = htons(ARPHRD_NETROM);
 		arp->ar_pro = htons(AX25_P_IP);
@@ -643,13 +643,13 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 #endif
 #endif
 
-#if defined(CONFIG_FDDI) || defined(CONFIG_FDDI_MODULE)
+#if IS_ENABLED(CONFIG_FDDI)
 	case ARPHRD_FDDI:
 		arp->ar_hrd = htons(ARPHRD_ETHER);
 		arp->ar_pro = htons(ETH_P_IP);
 		break;
 #endif
-#if defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
+#if IS_ENABLED(CONFIG_TR)
 	case ARPHRD_IEEE802_TR:
 		arp->ar_hrd = htons(ARPHRD_IEEE802);
 		arp->ar_pro = htons(ETH_P_IP);
@@ -1036,7 +1036,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 			return -EINVAL;
 	}
 	switch (dev->type) {
-#if defined(CONFIG_FDDI) || defined(CONFIG_FDDI_MODULE)
+#if IS_ENABLED(CONFIG_FDDI)
 	case ARPHRD_FDDI:
 		/*
 		 * According to RFC 1390, FDDI devices should accept ARP
@@ -1282,7 +1282,7 @@ void __init arp_init(void)
 }
 
 #ifdef CONFIG_PROC_FS
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+#if IS_ENABLED(CONFIG_AX25)
 
 /* ------------------------------------------------------------------------ */
 /*
@@ -1330,7 +1330,7 @@ static void arp_format_neigh_entry(struct seq_file *seq,
 
 	read_lock(&n->lock);
 	/* Convert hardware address to XX:XX:XX:XX ... form. */
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+#if IS_ENABLED(CONFIG_AX25)
 	if (hatype == ARPHRD_AX25 || hatype == ARPHRD_NETROM)
 		ax2asc2((ax25_address *)n->ha, hbuffer);
 	else {
@@ -1343,7 +1343,7 @@ static void arp_format_neigh_entry(struct seq_file *seq,
 	if (k != 0)
 		--k;
 	hbuffer[k] = 0;
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+#if IS_ENABLED(CONFIG_AX25)
 	}
 #endif
 	sprintf(tbuf, "%pI4", n->primary_key);
-- 
1.7.5.4
