From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [BK PATCH] 2.4 SCTP updates.
Date: Fri, 27 Feb 2004 12:31:18 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402271216200.12389@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Thanks for fixing the MSECS_TO_JIFFIES warning.

Here are a few updates to SCTP on top of the latest 2.4 BK tree. It includes
fixes to NIP6 macro compile error, incorrect packed attribute usage and
a bug with sinit_max_init_timeo behavior.

please do a
	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work

# This patch includes the following deltas:
#	           ChangeSet	1.1327  -> 1.1330
#	net/sctp/sm_statefuns.c	1.4     -> 1.5
#	     net/sctp/ipv6.c	1.5     -> 1.6
#	include/linux/sctp.h	1.4     -> 1.5
#	include/net/sctp/structs.h	1.5     -> 1.6
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/27	sri@us.ibm.com	1.1328
# [SCTP] Fix packed attribute usage.
# --------------------------------------------
# 04/02/27	sri@us.ibm.com	1.1329
# [SCTP] Fix NIP6 macro to take a ptr to struct in6_addr.
# --------------------------------------------
# 04/02/27	sri@us.ibm.com	1.1330
# [SCTP] Fix incorrect INIT process termination with sinit_max_init_timeo.
#
# Currently, sinit_max_init_timeo is treated as the maximum timeout
# value for INIT retransmissions and the INIT process is aborted when
# the timeout reaches this value. But as per the SCTP sockets API draft,
# sinit_max_init_timeo only limits the timeout. The INIT process should
# be aborted only after MAX_INIT_RETRANSMITS.
# --------------------------------------------
#
diff -Nru a/include/linux/sctp.h b/include/linux/sctp.h
--- a/include/linux/sctp.h	Fri Feb 27 12:06:12 2004
+++ b/include/linux/sctp.h	Fri Feb 27 12:06:12 2004
@@ -61,14 +61,14 @@
 	__u16 dest;
 	__u32 vtag;
 	__u32 checksum;
-} sctp_sctphdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_sctphdr_t;

 /* Section 3.2.  Chunk Field Descriptions. */
 typedef struct sctp_chunkhdr {
 	__u8 type;
 	__u8 flags;
 	__u16 length;
-} sctp_chunkhdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_chunkhdr_t;


 /* Section 3.2.  Chunk Type Values.
@@ -152,7 +152,7 @@
 typedef struct sctp_paramhdr {
 	__u16 type;
 	__u16 length;
-} sctp_paramhdr_t __attribute((packed));
+} __attribute__((packed)) sctp_paramhdr_t;

 typedef enum {

@@ -202,12 +202,12 @@
 	__u16 ssn;
 	__u32 ppid;
 	__u8  payload[0];
-} sctp_datahdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_datahdr_t;

 typedef struct sctp_data_chunk {
         sctp_chunkhdr_t chunk_hdr;
         sctp_datahdr_t  data_hdr;
-} sctp_data_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_data_chunk_t;

 /* DATA Chuck Specific Flags */
 enum {
@@ -232,48 +232,48 @@
 	__u16 num_inbound_streams;
 	__u32 initial_tsn;
 	__u8  params[0];
-} sctp_inithdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_inithdr_t;

 typedef struct sctp_init_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_inithdr_t init_hdr;
-} sctp_init_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_init_chunk_t;


 /* Section 3.3.2.1. IPv4 Address Parameter (5) */
 typedef struct sctp_ipv4addr_param {
 	sctp_paramhdr_t param_hdr;
 	struct in_addr  addr;
-} sctp_ipv4addr_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_ipv4addr_param_t;

 /* Section 3.3.2.1. IPv6 Address Parameter (6) */
 typedef struct sctp_ipv6addr_param {
 	sctp_paramhdr_t param_hdr;
 	struct in6_addr addr;
-} sctp_ipv6addr_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_ipv6addr_param_t;

 /* Section 3.3.2.1 Cookie Preservative (9) */
 typedef struct sctp_cookie_preserve_param {
 	sctp_paramhdr_t param_hdr;
 	uint32_t        lifespan_increment;
-} sctp_cookie_preserve_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_cookie_preserve_param_t;

 /* Section 3.3.2.1 Host Name Address (11) */
 typedef struct sctp_hostname_param {
 	sctp_paramhdr_t param_hdr;
 	uint8_t hostname[0];
-} sctp_hostname_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_hostname_param_t;

 /* Section 3.3.2.1 Supported Address Types (12) */
 typedef struct sctp_supported_addrs_param {
 	sctp_paramhdr_t param_hdr;
 	uint16_t types[0];
-} sctp_supported_addrs_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_supported_addrs_param_t;

 /* Appendix A. ECN Capable (32768) */
 typedef struct sctp_ecn_capable_param {
 	sctp_paramhdr_t param_hdr;
-} sctp_ecn_capable_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_ecn_capable_param_t;



@@ -287,13 +287,13 @@
 typedef struct sctp_cookie_param {
 	sctp_paramhdr_t p;
 	__u8 body[0];
-} sctp_cookie_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_cookie_param_t;

 /* Section 3.3.3.1 Unrecognized Parameters (8) */
 typedef struct sctp_unrecognized_param {
 	sctp_paramhdr_t param_hdr;
 	sctp_paramhdr_t unrecognized;
-} sctp_unrecognized_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_unrecognized_param_t;



@@ -308,7 +308,7 @@
 typedef struct sctp_gap_ack_block {
 	__u16 start;
 	__u16 end;
-} sctp_gap_ack_block_t __attribute__((packed));
+} __attribute__((packed)) sctp_gap_ack_block_t;

 typedef uint32_t sctp_dup_tsn_t;

@@ -323,12 +323,12 @@
 	__u16 num_gap_ack_blocks;
 	__u16 num_dup_tsns;
 	sctp_sack_variable_t variable[0];
-} sctp_sackhdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_sackhdr_t;

 typedef struct sctp_sack_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_sackhdr_t sack_hdr;
-} sctp_sack_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_sack_chunk_t;


 /* RFC 2960.  Section 3.3.5 Heartbeat Request (HEARTBEAT) (4):
@@ -340,12 +340,12 @@

 typedef struct sctp_heartbeathdr {
 	sctp_paramhdr_t info;
-} sctp_heartbeathdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_heartbeathdr_t;

 typedef struct sctp_heartbeat_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_heartbeathdr_t hb_hdr;
-} sctp_heartbeat_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_heartbeat_chunk_t;


 /* For the abort and shutdown ACK we must carry the init tag in the
@@ -354,7 +354,7 @@
  */
 typedef struct sctp_abort_chunk {
         sctp_chunkhdr_t uh;
-} sctp_abort_chunkt_t __attribute__((packed));
+} __attribute__((packed)) sctp_abort_chunkt_t;


 /* For the graceful shutdown we must carry the tag (in common header)
@@ -362,14 +362,12 @@
  */
 typedef struct sctp_shutdownhdr {
 	__u32 cum_tsn_ack;
-} sctp_shutdownhdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_shutdownhdr_t;

 struct sctp_shutdown_chunk_t {
         sctp_chunkhdr_t    chunk_hdr;
         sctp_shutdownhdr_t shutdown_hdr;
-} __attribute__((packed));
-
-
+} __attribute__ ((packed));

 /* RFC 2960.  Section 3.3.10 Operation Error (ERROR) (9) */

@@ -377,12 +375,12 @@
 	__u16 cause;
 	__u16 length;
 	__u8  variable[0];
-} sctp_errhdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_errhdr_t;

 typedef struct sctp_operr_chunk {
         sctp_chunkhdr_t chunk_hdr;
 	sctp_errhdr_t   err_hdr;
-} sctp_operr_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_operr_chunk_t;

 /* RFC 2960 3.3.10 - Operation Error
  *
@@ -460,7 +458,7 @@
 typedef struct sctp_ecne_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_ecnehdr_t ence_hdr;
-} sctp_ecne_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_ecne_chunk_t;

 /* RFC 2960.  Appendix A.  Explicit Congestion Notification.
  *   Congestion Window Reduced (CWR) (13)
@@ -472,7 +470,7 @@
 typedef struct sctp_cwr_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_cwrhdr_t cwr_hdr;
-} sctp_cwr_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_cwr_chunk_t;

 /*
  * ADDIP Section 3.1 New Chunk Types
@@ -513,16 +511,16 @@
 typedef struct sctp_addip_param {
 	sctp_paramhdr_t	param_hdr;
 	__u32		crr_id;
-}sctp_addip_param_t __attribute__((packed));
+} __attribute__((packed)) sctp_addip_param_t;

 typedef struct sctp_addiphdr {
 	__u32	serial;
 	__u8	params[0];
-} sctp_addiphdr_t __attribute__((packed));
+} __attribute__((packed)) sctp_addiphdr_t;

 typedef struct sctp_addip_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	sctp_addiphdr_t addip_hdr;
-} sctp_addip_chunk_t __attribute__((packed));
+} __attribute__((packed)) sctp_addip_chunk_t;

 #endif /* __LINUX_SCTP_H__ */
diff -Nru a/include/net/sctp/structs.h b/include/net/sctp/structs.h
--- a/include/net/sctp/structs.h	Fri Feb 27 12:06:12 2004
+++ b/include/net/sctp/structs.h	Fri Feb 27 12:06:12 2004
@@ -369,7 +369,7 @@
 	struct sctp_paramhdr param_hdr;
 	union sctp_addr daddr;
 	unsigned long sent_at;
-} sctp_sender_hb_info_t __attribute__((packed));
+} __attribute__((packed)) sctp_sender_hb_info_t;

 /*
  *  RFC 2960 1.3.2 Sequenced Delivery within Streams
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	Fri Feb 27 12:06:12 2004
+++ b/net/sctp/ipv6.c	Fri Feb 27 12:06:12 2004
@@ -82,14 +82,14 @@

 /* FIXME: This macro needs to be moved to a common header file. */
 #define NIP6(addr) \
-	ntohs((addr).s6_addr16[0]), \
-	ntohs((addr).s6_addr16[1]), \
-	ntohs((addr).s6_addr16[2]), \
-	ntohs((addr).s6_addr16[3]), \
-	ntohs((addr).s6_addr16[4]), \
-	ntohs((addr).s6_addr16[5]), \
-	ntohs((addr).s6_addr16[6]), \
-	ntohs((addr).s6_addr16[7])
+	ntohs((addr)->s6_addr16[0]), \
+	ntohs((addr)->s6_addr16[1]), \
+	ntohs((addr)->s6_addr16[2]), \
+	ntohs((addr)->s6_addr16[3]), \
+	ntohs((addr)->s6_addr16[4]), \
+	ntohs((addr)->s6_addr16[5]), \
+	ntohs((addr)->s6_addr16[6]), \
+	ntohs((addr)->s6_addr16[7])

 /* ICMP error handler. */
 void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -181,13 +181,13 @@
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
 		fl.fl6_dst = rt0->addr;
 	}
-#if 0
+
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, "
 			  "src:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x "
 			  "dst:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
 			  __FUNCTION__, skb, skb->len,
 			  NIP6(fl.fl6_src), NIP6(fl.fl6_dst));
-#endif
+
 	SCTP_INC_STATS(SctpOutSCTPPacks);

 	return ip6_xmit(sk, skb, &fl, np->opt);
@@ -226,7 +226,7 @@
 		SCTP_DEBUG_PRINTK(
 			"rt6_dst:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x "
 			"rt6_src:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
-			NIP6(rt->rt6i_dst.addr), NIP6(rt->rt6i_src.addr));
+			NIP6(&rt->rt6i_dst.addr), NIP6(&rt->rt6i_src.addr));
 	} else {
 		SCTP_DEBUG_PRINTK("NO ROUTE\n");
 	}
@@ -273,13 +273,13 @@

 	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p "
 			  "daddr:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x ",
-			  __FUNCTION__, asoc, dst, NIP6(daddr->v6.sin6_addr));
+			  __FUNCTION__, asoc, dst, NIP6(&daddr->v6.sin6_addr));

 	if (!asoc) {
 		ipv6_get_saddr(dst, &daddr->v6.sin6_addr,&saddr->v6.sin6_addr);
 		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: "
 				  "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
-				  NIP6(saddr->v6.sin6_addr));
+				  NIP6(&saddr->v6.sin6_addr));
 		return;
 	}

@@ -308,12 +308,12 @@
 		memcpy(saddr, baddr, sizeof(union sctp_addr));
 		SCTP_DEBUG_PRINTK("saddr: "
 				  "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
-				  NIP6(saddr->v6.sin6_addr));
+				  NIP6(&saddr->v6.sin6_addr));
 	} else {
 		printk(KERN_ERR "%s: asoc:%p Could not find a valid source "
 		       "address for the "
 		       "dest:%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
-		       __FUNCTION__, asoc, NIP6(daddr->v6.sin6_addr));
+		       __FUNCTION__, asoc, NIP6(&daddr->v6.sin6_addr));
 	}

 	sctp_read_unlock(addr_lock);
@@ -678,7 +678,7 @@
 static void sctp_v6_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
 {
 	seq_printf(seq, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x ",
-		   NIP6(addr->v6.sin6_addr));
+		   NIP6(&addr->v6.sin6_addr));
 }

 /* Initialize a PF_INET6 socket msg_name. */
diff -Nru a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
--- a/net/sctp/sm_statefuns.c	Fri Feb 27 12:06:12 2004
+++ b/net/sctp/sm_statefuns.c	Fri Feb 27 12:06:12 2004
@@ -4272,8 +4272,7 @@

 	SCTP_DEBUG_PRINTK("Timer T1 expired.\n");

-	if ((timeout < asoc->max_init_timeo) &&
-	    (attempts < asoc->max_init_attempts)) {
+	if (attempts < asoc->max_init_attempts) {
 		switch (timer) {
 		case SCTP_EVENT_TIMEOUT_T1_INIT:
 			bp = (struct sctp_bind_addr *) &asoc->base.bind_addr;
