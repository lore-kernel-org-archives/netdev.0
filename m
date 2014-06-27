From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v2] 6lowpan: mac802154: fix coding style issues
Date: Fri, 27 Jun 2014 09:37:25 +0530
Message-ID: <1403842045-8354-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	linux-kernel@vger.kernel.org, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49595 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaF0EIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 00:08:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixed the coding style issues reported by checkpatch.pl

following issues fixed:
	CHECK: Alignment should match open parenthesis
	WARNING: line over 80 characters
	CHECK: Blank lines aren't necessary before a close brace '}'
	WARNING: networking block comments don't use an empty /* line, use /* Comment...
	WARNING: Missing a blank line after declarations
	WARNING: networking block comments start with * on subsequent lines
	CHECK: braces {} should be used on all arms of this statement

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 net/ieee802154/6lowpan_iphc.c  |  113 ++++++++++++++++++----------------------
 net/ieee802154/6lowpan_rtnl.c  |   16 +++---
 net/ieee802154/af_ieee802154.c |   26 +++++----
 net/ieee802154/dgram.c         |   28 +++++-----
 net/ieee802154/ieee802154.h    |    2 +-
 net/ieee802154/netlink.c       |    4 +-
 net/ieee802154/nl-mac.c        |   48 +++++++++--------
 net/ieee802154/nl-phy.c        |   23 ++++----
 net/ieee802154/raw.c           |   14 +++--
 net/ieee802154/reassembly.c    |    1 +
 net/ieee802154/wpan-class.c    |   10 ++--
 net/mac802154/ieee802154_dev.c |    4 +-
 net/mac802154/llsec.c          |    1 +
 net/mac802154/mib.c            |    7 +--
 net/mac802154/tx.c             |    1 +
 15 files changed, 153 insertions(+), 145 deletions(-)

diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
index 211b568..511ddee 100644
--- a/net/ieee802154/6lowpan_iphc.c
+++ b/net/ieee802154/6lowpan_iphc.c
@@ -3,8 +3,7 @@
  * written by Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
  */
 
-/*
- * Based on patches from Jon Smirl <jonsmirl@gmail.com>
+/* Based on patches from Jon Smirl <jonsmirl@gmail.com>
  * Copyright (c) 2011 Jon Smirl <jonsmirl@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
@@ -58,16 +57,15 @@
 #include <net/ipv6.h>
 #include <net/af_ieee802154.h>
 
-/*
- * Uncompress address function for source and
+/* Uncompress address function for source and
  * destination address(non-multicast).
  *
  * address_mode is sam value or dam value.
  */
 static int uncompress_addr(struct sk_buff *skb,
-				struct in6_addr *ipaddr, const u8 address_mode,
-				const u8 *lladdr, const u8 addr_type,
-				const u8 addr_len)
+			   struct in6_addr *ipaddr, const u8 address_mode,
+			   const u8 *lladdr, const u8 addr_type,
+			   const u8 addr_len)
 {
 	bool fail;
 
@@ -140,13 +138,12 @@ static int uncompress_addr(struct sk_buff *skb,
 	return 0;
 }
 
-/*
- * Uncompress address function for source context
+/* Uncompress address function for source context
  * based address(non-multicast).
  */
 static int uncompress_context_based_src_addr(struct sk_buff *skb,
-						struct in6_addr *ipaddr,
-						const u8 sam)
+					     struct in6_addr *ipaddr,
+					     const u8 sam)
 {
 	switch (sam) {
 	case LOWPAN_IPHC_ADDR_00:
@@ -175,13 +172,13 @@ static int uncompress_context_based_src_addr(struct sk_buff *skb,
 }
 
 static int skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr,
-		struct net_device *dev, skb_delivery_cb deliver_skb)
+		       struct net_device *dev, skb_delivery_cb deliver_skb)
 {
 	struct sk_buff *new;
 	int stat;
 
-	new = skb_copy_expand(skb, sizeof(struct ipv6hdr), skb_tailroom(skb),
-								GFP_ATOMIC);
+	new = skb_copy_expand(skb, sizeof(struct ipv6hdr),
+			      skb_tailroom(skb), GFP_ATOMIC);
 	kfree_skb(skb);
 
 	if (!new)
@@ -196,7 +193,7 @@ static int skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr,
 	new->dev = dev;
 
 	raw_dump_table(__func__, "raw skb data dump before receiving",
-			new->data, new->len);
+		       new->data, new->len);
 
 	stat = deliver_skb(new, dev);
 
@@ -210,8 +207,8 @@ static int skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr,
  */
 static int
 lowpan_uncompress_multicast_daddr(struct sk_buff *skb,
-		struct in6_addr *ipaddr,
-		const u8 dam)
+				  struct in6_addr *ipaddr,
+				  const u8 dam)
 {
 	bool fail;
 
@@ -314,8 +311,7 @@ uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 			fail |= lowpan_fetch_skb(skb, &uh->check, 2);
 		}
 
-		/*
-		 * UDP lenght needs to be infered from the lower layers
+		/* UDP lenght needs to be infered from the lower layers
 		 * here, we obtain the hint from the remaining size of the
 		 * frame
 		 */
@@ -338,16 +334,17 @@ err:
 static const u8 lowpan_ttl_values[] = { 0, 1, 64, 255 };
 
 int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
-		const u8 *saddr, const u8 saddr_type, const u8 saddr_len,
-		const u8 *daddr, const u8 daddr_type, const u8 daddr_len,
-		u8 iphc0, u8 iphc1, skb_delivery_cb deliver_skb)
+			const u8 *saddr, const u8 saddr_type,
+			const u8 saddr_len, const u8 *daddr,
+			const u8 daddr_type, const u8 daddr_len,
+			u8 iphc0, u8 iphc1, skb_delivery_cb deliver_skb)
 {
 	struct ipv6hdr hdr = {};
 	u8 tmp, num_context = 0;
 	int err;
 
 	raw_dump_table(__func__, "raw skb data dump uncompressed",
-				skb->data, skb->len);
+		       skb->data, skb->len);
 
 	/* another if the CID flag is set */
 	if (iphc1 & LOWPAN_IPHC_CID) {
@@ -360,8 +357,7 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 
 	/* Traffic Class and Flow Label */
 	switch ((iphc0 & LOWPAN_IPHC_TF) >> 3) {
-	/*
-	 * Traffic Class and FLow Label carried in-line
+	/* Traffic Class and FLow Label carried in-line
 	 * ECN + DSCP + 4-bit Pad + Flow Label (4 bytes)
 	 */
 	case 0: /* 00b */
@@ -374,8 +370,7 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 		hdr.flow_lbl[0] = ((tmp >> 2) & 0x30) | (tmp << 6) |
 					(hdr.flow_lbl[0] & 0x0f);
 		break;
-	/*
-	 * Traffic class carried in-line
+	/* Traffic class carried in-line
 	 * ECN + DSCP (1 byte), Flow Label is elided
 	 */
 	case 2: /* 10b */
@@ -385,8 +380,7 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 		hdr.priority = ((tmp >> 2) & 0x0f);
 		hdr.flow_lbl[0] = ((tmp << 6) & 0xC0) | ((tmp >> 2) & 0x30);
 		break;
-	/*
-	 * Flow Label carried in-line
+	/* Flow Label carried in-line
 	 * ECN + 2-bit Pad + Flow Label (3 bytes), DSCP is elided
 	 */
 	case 1: /* 01b */
@@ -415,9 +409,9 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	/* Hop Limit */
-	if ((iphc0 & 0x03) != LOWPAN_IPHC_TTL_I)
+	if ((iphc0 & 0x03) != LOWPAN_IPHC_TTL_I) {
 		hdr.hop_limit = lowpan_ttl_values[iphc0 & 0x03];
-	else {
+	} else {
 		if (lowpan_fetch_skb_u8(skb, &(hdr.hop_limit)))
 			goto drop;
 	}
@@ -429,12 +423,12 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 		/* Source address context based uncompression */
 		pr_debug("SAC bit is set. Handle context based source address.\n");
 		err = uncompress_context_based_src_addr(
-				skb, &hdr.saddr, tmp);
+						skb, &hdr.saddr, tmp);
 	} else {
 		/* Source address uncompression */
 		pr_debug("source address stateless compression\n");
 		err = uncompress_addr(skb, &hdr.saddr, tmp, saddr,
-					saddr_type, saddr_len);
+				      saddr_type, saddr_len);
 	}
 
 	/* Check on error of previous branch */
@@ -457,9 +451,9 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 		}
 	} else {
 		err = uncompress_addr(skb, &hdr.daddr, tmp, daddr,
-					daddr_type, daddr_len);
+				      daddr_type, daddr_len);
 		pr_debug("dest: stateless compression mode %d dest %pI6c\n",
-			tmp, &hdr.daddr);
+			 tmp, &hdr.daddr);
 		if (err)
 			goto drop;
 	}
@@ -468,11 +462,11 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 	if (iphc0 & LOWPAN_IPHC_NH_C) {
 		struct udphdr uh;
 		struct sk_buff *new;
+
 		if (uncompress_udp_header(skb, &uh))
 			goto drop;
 
-		/*
-		 * replace the compressed UDP head by the uncompressed UDP
+		/* replace the compressed UDP head by the uncompressed UDP
 		 * header
 		 */
 		new = skb_copy_expand(skb, sizeof(struct udphdr),
@@ -489,7 +483,7 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 		skb_copy_to_linear_data(skb, &uh, sizeof(struct udphdr));
 
 		raw_dump_table(__func__, "raw UDP header dump",
-				      (u8 *)&uh, sizeof(uh));
+			       (u8 *)&uh, sizeof(uh));
 
 		hdr.nexthdr = UIP_PROTO_UDP;
 	}
@@ -504,8 +498,8 @@ int lowpan_process_data(struct sk_buff *skb, struct net_device *dev,
 		hdr.version, ntohs(hdr.payload_len), hdr.nexthdr,
 		hdr.hop_limit, &hdr.daddr);
 
-	raw_dump_table(__func__, "raw header dump", (u8 *)&hdr,
-							sizeof(hdr));
+	raw_dump_table(__func__, "raw header dump",
+		       (u8 *)&hdr, sizeof(hdr));
 
 	return skb_deliver(skb, &hdr, dev, deliver_skb);
 
@@ -516,8 +510,8 @@ drop:
 EXPORT_SYMBOL_GPL(lowpan_process_data);
 
 static u8 lowpan_compress_addr_64(u8 **hc06_ptr, u8 shift,
-				const struct in6_addr *ipaddr,
-				const unsigned char *lladdr)
+				  const struct in6_addr *ipaddr,
+				  const unsigned char *lladdr)
 {
 	u8 val = 0;
 
@@ -530,14 +524,14 @@ static u8 lowpan_compress_addr_64(u8 **hc06_ptr, u8 shift,
 		*hc06_ptr += 2;
 		val = 2; /* 16-bits */
 		raw_dump_inline(NULL, "Compressed ipv6 addr is (16 bits)",
-			*hc06_ptr - 2, 2);
+				*hc06_ptr - 2, 2);
 	} else {
 		/* do not compress IID => xxxx::IID */
 		memcpy(*hc06_ptr, &ipaddr->s6_addr16[4], 8);
 		*hc06_ptr += 8;
 		val = 1; /* 64-bits */
 		raw_dump_inline(NULL, "Compressed ipv6 addr is (64 bits)",
-			*hc06_ptr - 8, 8);
+				*hc06_ptr - 8, 8);
 	}
 
 	return rol8(val, shift);
@@ -601,8 +595,8 @@ static void compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 }
 
 int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
-			unsigned short type, const void *_daddr,
-			const void *_saddr, unsigned int len)
+			   unsigned short type, const void *_daddr,
+			   const void *_saddr, unsigned int len)
 {
 	u8 tmp, iphc0, iphc1, *hc06_ptr;
 	struct ipv6hdr *hdr;
@@ -616,14 +610,13 @@ int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
 
 	pr_debug("IPv6 header dump:\n\tversion = %d\n\tlength  = %d\n"
 		 "\tnexthdr = 0x%02x\n\thop_lim = %d\n\tdest    = %pI6c\n",
-		hdr->version, ntohs(hdr->payload_len), hdr->nexthdr,
-		hdr->hop_limit, &hdr->daddr);
+		 hdr->version, ntohs(hdr->payload_len), hdr->nexthdr,
+		 hdr->hop_limit, &hdr->daddr);
 
 	raw_dump_table(__func__, "raw skb network header dump",
-		skb_network_header(skb), sizeof(struct ipv6hdr));
+		       skb_network_header(skb), sizeof(struct ipv6hdr));
 
-	/*
-	 * As we copy some bit-length fields, in the IPHC encoding bytes,
+	/* As we copy some bit-length fields, in the IPHC encoding bytes,
 	 * we sometimes use |=
 	 * If the field is 0, and the current bit value in memory is 1,
 	 * this does not work. We therefore reset the IPHC encoding here
@@ -639,11 +632,10 @@ int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
 			(unsigned char *)_daddr, IEEE802154_ADDR_LEN);
 
 	raw_dump_table(__func__,
-			"sending raw skb network uncompressed packet",
-			skb->data, skb->len);
+		       "sending raw skb network uncompressed packet",
+		       skb->data, skb->len);
 
-	/*
-	 * Traffic class, flow label
+	/* Traffic class, flow label
 	 * If flow label is 0, compress it. If traffic class is 0, compress it
 	 * We have to process both in the same time as the offset of traffic
 	 * class depends on the presence of version and flow label
@@ -654,11 +646,11 @@ int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
 	tmp = ((tmp & 0x03) << 6) | (tmp >> 2);
 
 	if (((hdr->flow_lbl[0] & 0x0F) == 0) &&
-	     (hdr->flow_lbl[1] == 0) && (hdr->flow_lbl[2] == 0)) {
+	    (hdr->flow_lbl[1] == 0) && (hdr->flow_lbl[2] == 0)) {
 		/* flow label can be compressed */
 		iphc0 |= LOWPAN_IPHC_FL_C;
 		if ((hdr->priority == 0) &&
-		   ((hdr->flow_lbl[0] & 0xF0) == 0)) {
+		    ((hdr->flow_lbl[0] & 0xF0) == 0)) {
 			/* compress (elide) all */
 			iphc0 |= LOWPAN_IPHC_TC_C;
 		} else {
@@ -669,7 +661,7 @@ int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
 	} else {
 		/* Flow label cannot be compressed */
 		if ((hdr->priority == 0) &&
-		   ((hdr->flow_lbl[0] & 0xF0) == 0)) {
+		    ((hdr->flow_lbl[0] & 0xF0) == 0)) {
 			/* compress only traffic class */
 			iphc0 |= LOWPAN_IPHC_TC_C;
 			*hc06_ptr = (tmp & 0xc0) | (hdr->flow_lbl[0] & 0x0F);
@@ -695,8 +687,7 @@ int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
 		hc06_ptr += 1;
 	}
 
-	/*
-	 * Hop limit
+	/* Hop limit
 	 * if 1:   compress, encoding is 01
 	 * if 64:  compress, encoding is 10
 	 * if 255: compress, encoding is 11
@@ -793,7 +784,7 @@ int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
 	pr_debug("header len %d skb %u\n", (int)(hc06_ptr - head), skb->len);
 
 	raw_dump_table(__func__, "raw skb data dump compressed",
-				skb->data, skb->len);
+		       skb->data, skb->len);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(lowpan_header_compress);
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index fe6bd7a..016b77e 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -80,14 +80,14 @@ lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
 static inline void lowpan_address_flip(u8 *src, u8 *dest)
 {
 	int i;
+
 	for (i = 0; i < IEEE802154_ADDR_LEN; i++)
 		(dest)[IEEE802154_ADDR_LEN - i - 1] = (src)[i];
 }
 
-static int lowpan_header_create(struct sk_buff *skb,
-			   struct net_device *dev,
-			   unsigned short type, const void *_daddr,
-			   const void *_saddr, unsigned int len)
+static int lowpan_header_create(struct sk_buff *skb, struct net_device *dev,
+				unsigned short type, const void *_daddr,
+				const void *_saddr, unsigned int len)
 {
 	const u8 *saddr = _saddr;
 	const u8 *daddr = _daddr;
@@ -144,7 +144,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 }
 
 static int lowpan_give_skb_to_devices(struct sk_buff *skb,
-					struct net_device *dev)
+				      struct net_device *dev)
 {
 	struct lowpan_dev_record *entry;
 	struct sk_buff *skb_cp;
@@ -368,24 +368,28 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 static struct wpan_phy *lowpan_get_phy(const struct net_device *dev)
 {
 	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
+
 	return ieee802154_mlme_ops(real_dev)->get_phy(real_dev);
 }
 
 static __le16 lowpan_get_pan_id(const struct net_device *dev)
 {
 	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
+
 	return ieee802154_mlme_ops(real_dev)->get_pan_id(real_dev);
 }
 
 static __le16 lowpan_get_short_addr(const struct net_device *dev)
 {
 	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
+
 	return ieee802154_mlme_ops(real_dev)->get_short_addr(real_dev);
 }
 
 static u8 lowpan_get_dsn(const struct net_device *dev)
 {
 	struct net_device *real_dev = lowpan_dev_info(dev)->real_dev;
+
 	return ieee802154_mlme_ops(real_dev)->get_dsn(real_dev);
 }
 
@@ -454,7 +458,7 @@ static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
-	struct packet_type *pt, struct net_device *orig_dev)
+		      struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct ieee802154_hdr hdr;
 	int ret;
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 351d9a9..29e0de6 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -40,9 +40,7 @@
 
 #include "af802154.h"
 
-/*
- * Utility function for families
- */
+/* Utility function for families */
 struct net_device*
 ieee802154_get_dev(struct net *net, const struct ieee802154_addr *addr)
 {
@@ -87,8 +85,8 @@ ieee802154_get_dev(struct net *net, const struct ieee802154_addr *addr)
 		rtnl_unlock();
 		break;
 	default:
-		pr_warning("Unsupported ieee802154 address type: %d\n",
-				addr->mode);
+		pr_warn("Unsupported ieee802154 address type: %d\n",
+			addr->mode);
 		break;
 	}
 
@@ -106,7 +104,7 @@ static int ieee802154_sock_release(struct socket *sock)
 	return 0;
 }
 static int ieee802154_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-		struct msghdr *msg, size_t len)
+				   struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 
@@ -114,7 +112,7 @@ static int ieee802154_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 }
 
 static int ieee802154_sock_bind(struct socket *sock, struct sockaddr *uaddr,
-		int addr_len)
+				int addr_len)
 {
 	struct sock *sk = sock->sk;
 
@@ -125,7 +123,7 @@ static int ieee802154_sock_bind(struct socket *sock, struct sockaddr *uaddr,
 }
 
 static int ieee802154_sock_connect(struct socket *sock, struct sockaddr *uaddr,
-			int addr_len, int flags)
+				   int addr_len, int flags)
 {
 	struct sock *sk = sock->sk;
 
@@ -139,7 +137,7 @@ static int ieee802154_sock_connect(struct socket *sock, struct sockaddr *uaddr,
 }
 
 static int ieee802154_dev_ioctl(struct sock *sk, struct ifreq __user *arg,
-		unsigned int cmd)
+				unsigned int cmd)
 {
 	struct ifreq ifr;
 	int ret = -ENOIOCTLCMD;
@@ -167,7 +165,7 @@ static int ieee802154_dev_ioctl(struct sock *sk, struct ifreq __user *arg,
 }
 
 static int ieee802154_sock_ioctl(struct socket *sock, unsigned int cmd,
-		unsigned long arg)
+				 unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 
@@ -238,8 +236,7 @@ static const struct proto_ops ieee802154_dgram_ops = {
 };
 
 
-/*
- * Create a socket. Initialise the socket, blank the addresses
+/* Create a socket. Initialise the socket, blank the addresses
  * set the state.
  */
 static int ieee802154_create(struct net *net, struct socket *sock,
@@ -301,13 +298,14 @@ static const struct net_proto_family ieee802154_family_ops = {
 };
 
 static int ieee802154_rcv(struct sk_buff *skb, struct net_device *dev,
-	struct packet_type *pt, struct net_device *orig_dev)
+			  struct packet_type *pt, struct net_device *orig_dev)
 {
 	if (!netif_running(dev))
 		goto drop;
 	pr_debug("got frame, type %d, dev %p\n", dev->type, dev);
 #ifdef DEBUG
-	print_hex_dump_bytes("ieee802154_rcv ", DUMP_PREFIX_NONE, skb->data, skb->len);
+	print_hex_dump_bytes("ieee802154_rcv ",
+			     DUMP_PREFIX_NONE, skb->data, skb->len);
 #endif
 
 	if (!net_eq(dev_net(dev), &init_net))
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 4f0ed87..ef2ad8a 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -149,8 +149,7 @@ static int dgram_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		spin_lock_bh(&sk->sk_receive_queue.lock);
 		skb = skb_peek(&sk->sk_receive_queue);
 		if (skb != NULL) {
-			/*
-			 * We will only return the amount
+			/* We will only return the amount
 			 * of this packet since that is all
 			 * that will be read.
 			 */
@@ -161,12 +160,13 @@ static int dgram_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	}
 
 	}
+
 	return -ENOIOCTLCMD;
 }
 
 /* FIXME: autobind */
 static int dgram_connect(struct sock *sk, struct sockaddr *uaddr,
-			int len)
+			 int len)
 {
 	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
 	struct dgram_sock *ro = dgram_sk(sk);
@@ -205,7 +205,7 @@ static int dgram_disconnect(struct sock *sk, int flags)
 }
 
 static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
-		struct msghdr *msg, size_t size)
+			 struct msghdr *msg, size_t size)
 {
 	struct net_device *dev;
 	unsigned int mtu;
@@ -248,8 +248,8 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
 	skb = sock_alloc_send_skb(sk, hlen + tlen + size,
-			msg->msg_flags & MSG_DONTWAIT,
-			&err);
+				  msg->msg_flags & MSG_DONTWAIT,
+				  &err);
 	if (!skb)
 		goto out_dev;
 
@@ -262,7 +262,8 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	cb->ackreq = ro->want_ack;
 
 	if (msg->msg_name) {
-		DECLARE_SOCKADDR(struct sockaddr_ieee802154*, daddr, msg->msg_name);
+		DECLARE_SOCKADDR(struct sockaddr_ieee802154*,
+				 daddr, msg->msg_name);
 
 		ieee802154_addr_from_sa(&dst_addr, &daddr->addr);
 	} else {
@@ -304,8 +305,8 @@ out:
 }
 
 static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
-		struct msghdr *msg, size_t len, int noblock, int flags,
-		int *addr_len)
+			 struct msghdr *msg, size_t len, int noblock,
+			 int flags, int *addr_len)
 {
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
@@ -398,6 +399,7 @@ int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
 					  dgram_sk(sk))) {
 			if (prev) {
 				struct sk_buff *clone;
+
 				clone = skb_clone(skb, GFP_ATOMIC);
 				if (clone)
 					dgram_rcv_skb(prev, clone);
@@ -407,9 +409,9 @@ int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
 		}
 	}
 
-	if (prev)
+	if (prev) {
 		dgram_rcv_skb(prev, skb);
-	else {
+	} else {
 		kfree_skb(skb);
 		ret = NET_RX_DROP;
 	}
@@ -419,7 +421,7 @@ int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
 }
 
 static int dgram_getsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int __user *optlen)
+			    char __user *optval, int __user *optlen)
 {
 	struct dgram_sock *ro = dgram_sk(sk);
 
@@ -463,7 +465,7 @@ static int dgram_getsockopt(struct sock *sk, int level, int optname,
 }
 
 static int dgram_setsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, unsigned int optlen)
+			    char __user *optval, unsigned int optlen)
 {
 	struct dgram_sock *ro = dgram_sk(sk);
 	struct net *net = sock_net(sk);
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index 8b83a23..5d352f8 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -43,7 +43,7 @@ struct genl_info;
 struct sk_buff *ieee802154_nl_create(int flags, u8 req);
 int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group);
 struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
-		int flags, u8 req);
+					int flags, u8 req);
 int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info);
 
 extern struct genl_family nl802154_family;
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 26efcf4..9222966 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -52,7 +52,7 @@ struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 
 	spin_lock_irqsave(&ieee802154_seq_lock, f);
 	hdr = genlmsg_put(msg, 0, ieee802154_seq_num++,
-			&nl802154_family, flags, req);
+			  &nl802154_family, flags, req);
 	spin_unlock_irqrestore(&ieee802154_seq_lock, f);
 	if (!hdr) {
 		nlmsg_free(msg);
@@ -86,7 +86,7 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
 		return NULL;
 
 	hdr = genlmsg_put_reply(msg, info,
-			&nl802154_family, flags, req);
+				&nl802154_family, flags, req);
 	if (!hdr) {
 		nlmsg_free(msg);
 		return NULL;
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index a3281b8..c6bfe22 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -60,7 +60,8 @@ static __le16 nla_get_shortaddr(const struct nlattr *nla)
 }
 
 int ieee802154_nl_assoc_indic(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 cap)
+			      struct ieee802154_addr *addr,
+			      u8 cap)
 {
 	struct sk_buff *msg;
 
@@ -93,7 +94,7 @@ nla_put_failure:
 EXPORT_SYMBOL(ieee802154_nl_assoc_indic);
 
 int ieee802154_nl_assoc_confirm(struct net_device *dev, __le16 short_addr,
-		u8 status)
+				u8 status)
 {
 	struct sk_buff *msg;
 
@@ -119,7 +120,8 @@ nla_put_failure:
 EXPORT_SYMBOL(ieee802154_nl_assoc_confirm);
 
 int ieee802154_nl_disassoc_indic(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 reason)
+				 struct ieee802154_addr *addr,
+				 u8 reason)
 {
 	struct sk_buff *msg;
 
@@ -205,8 +207,9 @@ nla_put_failure:
 EXPORT_SYMBOL(ieee802154_nl_beacon_indic);
 
 int ieee802154_nl_scan_confirm(struct net_device *dev,
-		u8 status, u8 scan_type, u32 unscanned, u8 page,
-		u8 *edl/* , struct list_head *pan_desc_list */)
+			       u8 status, u8 scan_type,
+			       u32 unscanned, u8 page,
+			       u8 *edl/* , struct list_head *pan_desc_list */)
 {
 	struct sk_buff *msg;
 
@@ -260,7 +263,7 @@ nla_put_failure:
 EXPORT_SYMBOL(ieee802154_nl_start_confirm);
 
 static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
-	u32 seq, int flags, struct net_device *dev)
+				    u32 seq, int flags, struct net_device *dev)
 {
 	void *hdr;
 	struct wpan_phy *phy;
@@ -270,7 +273,7 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 	pr_debug("%s\n", __func__);
 
 	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, flags,
-		IEEE802154_LIST_IFACE);
+			  IEEE802154_LIST_IFACE);
 	if (!hdr)
 		goto out;
 
@@ -330,14 +333,16 @@ static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
 
 	if (info->attrs[IEEE802154_ATTR_DEV_NAME]) {
 		char name[IFNAMSIZ + 1];
+
 		nla_strlcpy(name, info->attrs[IEEE802154_ATTR_DEV_NAME],
-				sizeof(name));
+			    sizeof(name));
 		dev = dev_get_by_name(&init_net, name);
-	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX])
+	} else if (info->attrs[IEEE802154_ATTR_DEV_INDEX]) {
 		dev = dev_get_by_index(&init_net,
 			nla_get_u32(info->attrs[IEEE802154_ATTR_DEV_INDEX]));
-	else
+	} else {
 		return NULL;
+	}
 
 	if (!dev)
 		return NULL;
@@ -435,7 +440,7 @@ int ieee802154_disassociate_req(struct sk_buff *skb, struct genl_info *info)
 	int ret = -EOPNOTSUPP;
 
 	if ((!info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] &&
-		!info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]) ||
+	    !info->attrs[IEEE802154_ATTR_DEST_SHORT_ADDR]) ||
 	    !info->attrs[IEEE802154_ATTR_REASON])
 		return -EINVAL;
 
@@ -464,8 +469,7 @@ out:
 	return ret;
 }
 
-/*
- * PANid, channel, beacon_order = 15, superframe_order = 15,
+/* PANid, channel, beacon_order = 15, superframe_order = 15,
  * PAN_coordinator, battery_life_extension = 0,
  * coord_realignment = 0, security_enable = 0
 */
@@ -559,8 +563,8 @@ int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 		page = 0;
 
 
-	ret = ieee802154_mlme_ops(dev)->scan_req(dev, type, channels, page,
-			duration);
+	ret = ieee802154_mlme_ops(dev)->scan_req(dev, type, channels,
+						 page, duration);
 
 out:
 	dev_put(dev);
@@ -570,7 +574,8 @@ out:
 int ieee802154_list_iface(struct sk_buff *skb, struct genl_info *info)
 {
 	/* Request for interface name, index, type, IEEE address,
-	   PAN Id, short address */
+	 * PAN Id, short address
+	 */
 	struct sk_buff *msg;
 	struct net_device *dev = NULL;
 	int rc = -ENOBUFS;
@@ -586,7 +591,7 @@ int ieee802154_list_iface(struct sk_buff *skb, struct genl_info *info)
 		goto out_dev;
 
 	rc = ieee802154_nl_fill_iface(msg, info->snd_portid, info->snd_seq,
-			0, dev);
+				      0, dev);
 	if (rc < 0)
 		goto out_free;
 
@@ -598,7 +603,6 @@ out_free:
 out_dev:
 	dev_put(dev);
 	return rc;
-
 }
 
 int ieee802154_dump_iface(struct sk_buff *skb, struct netlink_callback *cb)
@@ -616,7 +620,8 @@ int ieee802154_dump_iface(struct sk_buff *skb, struct netlink_callback *cb)
 			goto cont;
 
 		if (ieee802154_nl_fill_iface(skb, NETLINK_CB(cb->skb).portid,
-			cb->nlh->nlmsg_seq, NLM_F_MULTI, dev) < 0)
+					     cb->nlh->nlmsg_seq,
+					     NLM_F_MULTI, dev) < 0)
 			break;
 cont:
 		idx++;
@@ -765,6 +770,7 @@ ieee802154_llsec_parse_key_id(struct genl_info *info,
 	case IEEE802154_SCF_KEY_SHORT_INDEX:
 	{
 		u32 source = nla_get_u32(info->attrs[IEEE802154_ATTR_LLSEC_KEY_SOURCE_SHORT]);
+
 		desc->short_source = cpu_to_le32(source);
 		break;
 	}
@@ -842,7 +848,7 @@ int ieee802154_llsec_getparams(struct sk_buff *skb, struct genl_info *info)
 		goto out_dev;
 
 	hdr = genlmsg_put(msg, 0, info->snd_seq, &nl802154_family, 0,
-		IEEE802154_LLSEC_GETPARAMS);
+			  IEEE802154_LLSEC_GETPARAMS);
 	if (!hdr)
 		goto out_free;
 
@@ -946,7 +952,7 @@ struct llsec_dump_data {
 
 static int
 ieee802154_llsec_dump_table(struct sk_buff *skb, struct netlink_callback *cb,
-			    int (*step)(struct llsec_dump_data*))
+			    int (*step)(struct llsec_dump_data *))
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_device *dev;
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 89b265a..972baf8 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -36,7 +36,7 @@
 #include "ieee802154.h"
 
 static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
-	u32 seq, int flags, struct wpan_phy *phy)
+				  u32 seq, int flags, struct wpan_phy *phy)
 {
 	void *hdr;
 	int i, pages = 0;
@@ -48,7 +48,7 @@ static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 		return -EMSGSIZE;
 
 	hdr = genlmsg_put(msg, 0, seq, &nl802154_family, flags,
-		IEEE802154_LIST_PHY);
+			  IEEE802154_LIST_PHY);
 	if (!hdr)
 		goto out;
 
@@ -80,7 +80,8 @@ out:
 int ieee802154_list_phy(struct sk_buff *skb, struct genl_info *info)
 {
 	/* Request for interface name, index, type, IEEE address,
-	   PAN Id, short address */
+	 * PAN Id, short address
+	 */
 	struct sk_buff *msg;
 	struct wpan_phy *phy;
 	const char *name;
@@ -105,7 +106,7 @@ int ieee802154_list_phy(struct sk_buff *skb, struct genl_info *info)
 		goto out_dev;
 
 	rc = ieee802154_nl_fill_phy(msg, info->snd_portid, info->snd_seq,
-			0, phy);
+				    0, phy);
 	if (rc < 0)
 		goto out_free;
 
@@ -117,7 +118,6 @@ out_free:
 out_dev:
 	wpan_phy_put(phy);
 	return rc;
-
 }
 
 struct dump_phy_data {
@@ -137,10 +137,10 @@ static int ieee802154_dump_phy_iter(struct wpan_phy *phy, void *_data)
 		return 0;
 
 	rc = ieee802154_nl_fill_phy(data->skb,
-			NETLINK_CB(data->cb->skb).portid,
-			data->cb->nlh->nlmsg_seq,
-			NLM_F_MULTI,
-			phy);
+				    NETLINK_CB(data->cb->skb).portid,
+				    data->cb->nlh->nlmsg_seq,
+				    NLM_F_MULTI,
+				    phy);
 
 	if (rc < 0) {
 		data->idx--;
@@ -238,10 +238,9 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
 
 		addr.sa_family = ARPHRD_IEEE802154;
 		nla_memcpy(&addr.sa_data, info->attrs[IEEE802154_ATTR_HW_ADDR],
-				IEEE802154_ADDR_LEN);
+			   IEEE802154_ADDR_LEN);
 
-		/*
-		 * strangely enough, some callbacks (inetdev_event) from
+		/* strangely enough, some callbacks (inetdev_event) from
 		 * dev_set_mac_address require RTNL_LOCK
 		 */
 		rtnl_lock();
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 74d54fa..9d1f648 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -96,7 +96,7 @@ out:
 }
 
 static int raw_connect(struct sock *sk, struct sockaddr *uaddr,
-			int addr_len)
+		       int addr_len)
 {
 	return -ENOTSUPP;
 }
@@ -106,8 +106,8 @@ static int raw_disconnect(struct sock *sk, int flags)
 	return 0;
 }
 
-static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       size_t size)
+static int raw_sendmsg(struct kiocb *iocb, struct sock *sk,
+		       struct msghdr *msg, size_t size)
 {
 	struct net_device *dev;
 	unsigned int mtu;
@@ -145,7 +145,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
 	skb = sock_alloc_send_skb(sk, hlen + tlen + size,
-			msg->msg_flags & MSG_DONTWAIT, &err);
+				  msg->msg_flags & MSG_DONTWAIT, &err);
 	if (!skb)
 		goto out_dev;
 
@@ -235,7 +235,6 @@ void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb)
 		bh_lock_sock(sk);
 		if (!sk->sk_bound_dev_if ||
 		    sk->sk_bound_dev_if == dev->ifindex) {
-
 			struct sk_buff *clone;
 
 			clone = skb_clone(skb, GFP_ATOMIC);
@@ -248,13 +247,13 @@ void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb)
 }
 
 static int raw_getsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int __user *optlen)
+			  char __user *optval, int __user *optlen)
 {
 	return -EOPNOTSUPP;
 }
 
 static int raw_setsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, unsigned int optlen)
+			  char __user *optval, unsigned int optlen)
 {
 	return -EOPNOTSUPP;
 }
@@ -274,4 +273,3 @@ struct proto ieee802154_raw_prot = {
 	.getsockopt	= raw_getsockopt,
 	.setsockopt	= raw_setsockopt,
 };
-
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 6f1428c..b85bd3f 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -378,6 +378,7 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 	fq = fq_find(net, frag_info, &source, &dest);
 	if (fq != NULL) {
 		int ret;
+
 		spin_lock(&fq->q.lock);
 		ret = lowpan_frag_queue(fq, skb, frag_type);
 		spin_unlock(&fq->q.lock);
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 8d6f670..4955e0f 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -48,7 +48,8 @@ MASTER_SHOW(transmit_power, "%d +- 1 dB");
 MASTER_SHOW(cca_mode, "%d");
 
 static ssize_t channels_supported_show(struct device *dev,
-			    struct device_attribute *attr, char *buf)
+				       struct device_attribute *attr,
+				       char *buf)
 {
 	struct wpan_phy *phy = container_of(dev, struct wpan_phy, dev);
 	int ret;
@@ -57,7 +58,7 @@ static ssize_t channels_supported_show(struct device *dev,
 	mutex_lock(&phy->pib_lock);
 	for (i = 0; i < 32; i++) {
 		ret = snprintf(buf + len, PAGE_SIZE - len,
-				"%#09x\n", phy->channels_supported[i]);
+			       "%#09x\n", phy->channels_supported[i]);
 		if (ret < 0)
 			break;
 		len += ret;
@@ -80,6 +81,7 @@ ATTRIBUTE_GROUPS(pmib);
 static void wpan_phy_release(struct device *d)
 {
 	struct wpan_phy *phy = container_of(d, struct wpan_phy, dev);
+
 	kfree(phy);
 }
 
@@ -121,11 +123,12 @@ static int wpan_phy_iter(struct device *dev, void *_data)
 {
 	struct wpan_phy_iter_data *wpid = _data;
 	struct wpan_phy *phy = container_of(dev, struct wpan_phy, dev);
+
 	return wpid->fn(phy, wpid->data);
 }
 
 int wpan_phy_for_each(int (*fn)(struct wpan_phy *phy, void *data),
-		void *data)
+		      void *data)
 {
 	struct wpan_phy_iter_data wpid = {
 		.fn = fn,
@@ -197,6 +200,7 @@ EXPORT_SYMBOL(wpan_phy_free);
 static int __init wpan_phy_class_init(void)
 {
 	int rc;
+
 	rc = class_register(&wpan_phy_class);
 	if (rc)
 		goto err;
diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 2cf66d8..c4d4568 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -143,6 +143,7 @@ static void
 mac802154_del_iface(struct wpan_phy *phy, struct net_device *dev)
 {
 	struct mac802154_sub_if_data *sdata;
+
 	ASSERT_RTNL();
 
 	sdata = netdev_priv(dev);
@@ -276,7 +277,8 @@ ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 	}
 
 	priv = wpan_phy_priv(phy);
-	priv->hw.phy = priv->phy = phy;
+	priv->phy = phy;
+	priv->hw.phy = priv->phy;
 	priv->hw.priv = (char *)priv + ALIGN(sizeof(*priv), NETDEV_ALIGN);
 	priv->ops = ops;
 
diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index 1456f73..4570581 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -538,6 +538,7 @@ static int llsec_recover_addr(struct mac802154_llsec *sec,
 			      struct ieee802154_addr *addr)
 {
 	__le16 caddr = sec->params.coord_shortaddr;
+
 	addr->pan_id = sec->params.pan_id;
 
 	if (caddr == cpu_to_le16(IEEE802154_ADDR_BROADCAST)) {
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index 15aa2f2..868a040 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -175,9 +175,9 @@ static void phy_chan_notify(struct work_struct *work)
 
 	mutex_lock(&priv->hw->phy->pib_lock);
 	res = hw->ops->set_channel(&hw->hw, priv->page, priv->chan);
-	if (res)
+	if (res) {
 		pr_debug("set_channel failed\n");
-	else {
+	} else {
 		priv->hw->phy->current_channel = priv->chan;
 		priv->hw->phy->current_page = priv->page;
 	}
@@ -210,8 +210,9 @@ void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan)
 		INIT_WORK(&work->work, phy_chan_notify);
 		work->dev = dev;
 		queue_work(priv->hw->dev_workqueue, &work->work);
-	} else
+	} else {
 		mutex_unlock(&priv->hw->phy->pib_lock);
+	}
 }
 
 
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 6d16473..8124353 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -98,6 +98,7 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 	if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
 		u16 crc = crc_ccitt(0, skb->data, skb->len);
 		u8 *data = skb_put(skb, 2);
+
 		data[0] = crc & 0xff;
 		data[1] = crc >> 8;
 	}
-- 
1.7.9.5
