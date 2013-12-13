From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH] sctp: Reorder 'struc association' members to reduce its size
Date: Fri, 13 Dec 2013 13:51:04 +0800
Message-ID: <52AAA048.2040704@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:43459 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab3LMF55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 00:57:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Members of 'struct association' are not in appropriate order to
reuse compiler added padding on 64bit architectures. In this patch
we reorder those struct members and help reduce the size of the
structure from 2776 bytes to 2720 bytes on 64 bit architectures.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/structs.h | 59 +++++++++++++++++++++++-----------------------
 1 file changed, 29 insertions(+), 30 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 67b5d00..790fc42 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1361,12 +1361,6 @@ struct sctp_association {
 
 	/* This is all information about our peer.  */
 	struct {
-		/* rwnd
-		 *
-		 * Peer Rwnd   : Current calculated value of the peer's rwnd.
-		 */
-		__u32 rwnd;
-
 		/* transport_addr_list
 		 *
 		 * Peer	       : A list of SCTP transport addresses that the
@@ -1384,6 +1378,12 @@ struct sctp_association {
 		 */
 		struct list_head transport_addr_list;
 
+		/* rwnd
+		 *
+		 * Peer Rwnd   : Current calculated value of the peer's rwnd.
+		 */
+		__u32 rwnd;
+
 		/* transport_count
 		 *
 		 * Peer        : A count of the number of peer addresses
@@ -1466,6 +1466,20 @@ struct sctp_association {
 		 */
 		struct sctp_tsnmap tsn_map;
 
+		/* This mask is used to disable sending the ASCONF chunk
+		 * with specified parameter to peer.
+		 */
+		__be16 addip_disabled_mask;
+
+		/* These are capabilities which our peer advertised.  */
+		__u8	ecn_capable:1,      /* Can peer do ECN? */
+			ipv4_address:1,     /* Peer understands IPv4 addresses? */
+			ipv6_address:1,     /* Peer understands IPv6 addresses? */
+			hostname_address:1, /* Peer understands DNS addresses? */
+			asconf_capable:1,   /* Does peer support ADDIP? */
+			prsctp_capable:1,   /* Can peer do PR-SCTP? */
+			auth_capable:1;     /* Is peer doing SCTP-AUTH? */
+
 		/* Ack State   : This flag indicates if the next received
 		 *             : packet is to be responded to with a
 		 *             : SACK. This is initializedto 0.  When a packet
@@ -1480,25 +1494,11 @@ struct sctp_association {
 		__u32	sack_cnt;
 		__u32	sack_generation;
 
-		/* These are capabilities which our peer advertised.  */
-		__u8	ecn_capable:1,	    /* Can peer do ECN? */
-			ipv4_address:1,	    /* Peer understands IPv4 addresses? */
-			ipv6_address:1,	    /* Peer understands IPv6 addresses? */
-			hostname_address:1, /* Peer understands DNS addresses? */
-			asconf_capable:1,   /* Does peer support ADDIP? */
-			prsctp_capable:1,   /* Can peer do PR-SCTP? */
-			auth_capable:1;	    /* Is peer doing SCTP-AUTH? */
-
 		__u32   adaptation_ind;	 /* Adaptation Code point. */
 
-		/* This mask is used to disable sending the ASCONF chunk
-		 * with specified parameter to peer.
-		 */
-		__be16 addip_disabled_mask;
-
 		struct sctp_inithdr_host i;
-		int cookie_len;
 		void *cookie;
+		int cookie_len;
 
 		/* ADDIP Section 4.2 Upon reception of an ASCONF Chunk.
 		 * C1) ... "Peer-Serial-Number'. This value MUST be initialized to the
@@ -1530,14 +1530,14 @@ struct sctp_association {
 	 */
 	sctp_state_t state;
 
-	/* The cookie life I award for any cookie.  */
-	ktime_t cookie_life;
-
 	/* Overall     : The overall association error count.
 	 * Error Count : [Clear this any time I get something.]
 	 */
 	int overall_error_count;
 
+	/* The cookie life I award for any cookie.  */
+	ktime_t cookie_life;
+
 	/* These are the association's initial, max, and min RTO values.
 	 * These values will be initialized by system defaults, but can
 	 * be modified via the SCTP_RTOINFO socket option.
@@ -1592,10 +1592,9 @@ struct sctp_association {
 	/* Flags controlling Heartbeat, SACK delay, and Path MTU Discovery. */
 	__u32 param_flags;
 
+	__u32 sackfreq;
 	/* SACK delay timeout */
 	unsigned long sackdelay;
-	__u32 sackfreq;
-
 
 	unsigned long timeouts[SCTP_NUM_TIMEOUT_TYPES];
 	struct timer_list timers[SCTP_NUM_TIMEOUT_TYPES];
@@ -1603,12 +1602,12 @@ struct sctp_association {
 	/* Transport to which SHUTDOWN chunk was last sent.  */
 	struct sctp_transport *shutdown_last_sent_to;
 
-	/* How many times have we resent a SHUTDOWN */
-	int shutdown_retries;
-
 	/* Transport to which INIT chunk was last sent.  */
 	struct sctp_transport *init_last_sent_to;
 
+	/* How many times have we resent a SHUTDOWN */
+	int shutdown_retries;
+
 	/* Next TSN    : The next TSN number to be assigned to a new
 	 *	       : DATA chunk.  This is sent in the INIT or INIT
 	 *	       : ACK chunk to the peer and incremented each
@@ -1813,8 +1812,8 @@ struct sctp_association {
 	 * after reaching 4294967295.
 	 */
 	__u32 addip_serial;
-	union sctp_addr *asconf_addr_del_pending;
 	int src_out_of_asoc_ok;
+	union sctp_addr *asconf_addr_del_pending;
 	struct sctp_transport *new_transport;
 
 	/* SCTP AUTH: list of the endpoint shared keys.  These
-- 
1.7.12
