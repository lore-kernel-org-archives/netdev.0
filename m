From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Shrink struct dst_entry a bit
Date: Tue, 13 Mar 2007 14:48:14 +0100
Message-ID: <200703131448.15193.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36487 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965737AbXCMNsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 09:48:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The ICMP rate limiting state can be shorts, we don't send that many ICMPs.
Changing flags to short and reorder fields to be sorted by size to avoid holes.
Move cold fields towards the end.

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux-2.6.21-rc3-net/include/net/dst.h
===================================================================
--- linux-2.6.21-rc3-net.orig/include/net/dst.h
+++ linux-2.6.21-rc3-net/include/net/dst.h
@@ -40,26 +40,24 @@ struct dst_entry
 	struct rcu_head		rcu_head;
 	struct dst_entry	*child;
 	struct net_device       *dev;
-	short			error;
-	short			obsolete;
-	int			flags;
+	unsigned long		expires;
+	short			flags;
 #define DST_HOST		1
 #define DST_NOXFRM		2
 #define DST_NOPOLICY		4
 #define DST_NOHASH		8
 #define DST_BALANCED            0x10
-	unsigned long		expires;
+	short			error;
+	short			obsolete;
 
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		nfheader_len;	/* more non-fragment space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 
-	u32			metrics[RTAX_MAX];
-	struct dst_entry	*path;
-
-	unsigned long		rate_last;	/* rate limiting for ICMP */
-	unsigned long		rate_tokens;
+	unsigned short		rate_last;	/* rate limiting for ICMP */
+	unsigned short		rate_tokens;
 
+	struct dst_entry	*path;
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;
 	struct xfrm_state	*xfrm;
@@ -67,10 +65,6 @@ struct dst_entry
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 
-#ifdef CONFIG_NET_CLS_ROUTE
-	__u32			tclassid;
-#endif
-
 	struct  dst_ops	        *ops;
 		
 	unsigned long		lastuse;
@@ -82,6 +76,13 @@ struct dst_entry
 		struct rt6_info   *rt6_next;
 		struct dn_route  *dn_next;
 	};
+
+	u32			metrics[RTAX_MAX];
+
+#ifdef CONFIG_NET_CLS_ROUTE
+	__u32			tclassid;
+#endif
+
 	char			info[0];
 };
 
