From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] inet_opt space saving?
Date: Tue, 14 Sep 2004 15:12:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914151232.115c3eca@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks like there are lots of wasted bytes in the inet information
per socket. Does this look right? 

diff -Nru a/include/linux/ip.h b/include/linux/ip.h
--- a/include/linux/ip.h	2004-09-14 15:13:14 -07:00
+++ b/include/linux/ip.h	2004-09-14 15:13:14 -07:00
@@ -114,18 +114,18 @@
 	__u16			dport;		/* Destination port */
 	__u16			num;		/* Local port */
 	__u32			saddr;		/* Sending source */
-	int			uc_ttl;		/* Unicast TTL */
-	int			tos;		/* TOS */
-	unsigned	   	cmsg_flags;
 	struct ip_options	*opt;
 	__u16			sport;		/* Source port */
-	unsigned char		hdrincl;	/* Include headers ? */
-	__u8			mc_ttl;		/* Multicasting TTL */
-	__u8			mc_loop;	/* Loopback */
-	__u8			pmtudisc;
 	__u16			id;		/* ID counter for DF pkts */
-	unsigned		recverr : 1,
-				freebind : 1;
+	__s16			uc_ttl;		/* Unicast TTL */
+	__u8			mc_ttl;		/* Multicasting TTL */
+	__u8			tos;		/* TOS */
+	unsigned		mc_loop: 1,	/* Loopback */
+				hdrincl: 1,	/* Include headers ? */
+				recverr: 1,
+				freebind: 1,
+				cmsg_flags: 4,
+				pmtudisc: 2;
 	int			mc_index;	/* Multicast device index */
 	__u32			mc_addr;
 	struct ip_mc_socklist	*mc_list;	/* Group array */
