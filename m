From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 06/15] ax25: Make ax25_header and ax25_rebuild_header static
Date: Mon, 02 Mar 2015 00:04:31 -0600
Message-ID: <87ioek7x5c.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53516 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbCBGID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 01:08:03 -0500
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The only user is in ax25_ip.c so stop exporting these functions.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ax25.h |  3 ---
 net/ax25/ax25_ip.c | 18 ++++++++----------
 2 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index bf0396e9a5d3..7385a64b61b8 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -366,9 +366,6 @@ int ax25_kiss_rcv(struct sk_buff *, struct net_device *, struct packet_type *,
 		  struct net_device *);
 
 /* ax25_ip.c */
-int ax25_hard_header(struct sk_buff *, struct net_device *, unsigned short,
-		     const void *, const void *, unsigned int);
-int ax25_rebuild_header(struct sk_buff *);
 extern const struct header_ops ax25_header_ops;
 
 /* ax25_out.c */
diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index db3c283821d1..d93103ba8cec 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -46,9 +46,9 @@
 
 #ifdef CONFIG_INET
 
-int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
-		     unsigned short type, const void *daddr,
-		     const void *saddr, unsigned int len)
+static int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
+			    unsigned short type, const void *daddr,
+			    const void *saddr, unsigned int len)
 {
 	unsigned char *buff;
 
@@ -100,7 +100,7 @@ int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return -AX25_HEADER_LEN;	/* Unfinished header */
 }
 
-int ax25_rebuild_header(struct sk_buff *skb)
+static int ax25_rebuild_header(struct sk_buff *skb)
 {
 	struct sk_buff *ourskb;
 	unsigned char *bp  = skb->data;
@@ -218,14 +218,14 @@ put:
 
 #else	/* INET */
 
-int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
-		     unsigned short type, const void *daddr,
-		     const void *saddr, unsigned int len)
+static int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
+			    unsigned short type, const void *daddr,
+			    const void *saddr, unsigned int len)
 {
 	return -AX25_HEADER_LEN;
 }
 
-int ax25_rebuild_header(struct sk_buff *skb)
+static int ax25_rebuild_header(struct sk_buff *skb)
 {
 	return 1;
 }
@@ -237,7 +237,5 @@ const struct header_ops ax25_header_ops = {
 	.rebuild = ax25_rebuild_header,
 };
 
-EXPORT_SYMBOL(ax25_hard_header);
-EXPORT_SYMBOL(ax25_rebuild_header);
 EXPORT_SYMBOL(ax25_header_ops);
 
-- 
2.2.1
