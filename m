From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/11] [NET] Reorder struct inet_sock
Date: Wed, 9 Mar 2005 20:46:21 +0100
Message-ID: <20050309194621.GI31837@postel.suug.ch>
References: <20050309194521.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050309194521.GH31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


tos: int -> 8bit
uc_ttl: int -> 16 bit
cmsg_flags: int -> 16 bit
hdrincl: 8bit -> 1 bit
mc_loop: 8bit -> 1 bit

Saves 12 bytes together with the reordering.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.11-rc4.orig/include/linux/ip.h linux-2.6.11-rc4/include/linux/ip.h
--- linux-2.6.11-rc4.orig/include/linux/ip.h	2005-03-08 18:11:22.000000000 +0100
+++ linux-2.6.11-rc4/include/linux/ip.h	2005-03-08 20:26:37.000000000 +0100
@@ -121,18 +121,18 @@
 	__u16			dport;		/* Destination port */
 	__u16			num;		/* Local port */
 	__u32			saddr;		/* Sending source */
-	int			uc_ttl;		/* Unicast TTL */
-	int			tos;		/* TOS */
-	unsigned	   	cmsg_flags;
+	__s16			uc_ttl;		/* Unicast TTL */
+	__u16			cmsg_flags;
 	struct ip_options	*opt;
 	__u16			sport;		/* Source port */
-	unsigned char		hdrincl;	/* Include headers ? */
+	__u16			id;		/* ID counter for DF pkts */
+	__u8			tos;		/* TOS */
 	__u8			mc_ttl;		/* Multicasting TTL */
-	__u8			mc_loop;	/* Loopback */
 	__u8			pmtudisc;
-	__u16			id;		/* ID counter for DF pkts */
 	unsigned		recverr : 1,
-				freebind : 1;
+				freebind : 1,
+				hdrincl : 1,
+				mc_loop : 1;
 	int			mc_index;	/* Multicast device index */
 	__u32			mc_addr;
 	struct ip_mc_socklist	*mc_list;	/* Group array */
