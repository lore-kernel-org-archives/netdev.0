From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] netfilter6 ip6_packet_match doesn't properly skip exthdrs
Date: Thu, 30 Sep 2004 14:14:08 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040930121408.GG19083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This patch fixes a bug in the ip6_tables code that tries to skip extension
headers. Packets with extension headers were usually not matched because
the code was looking at the wrong offset inside the skb.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.8.nf/net/ipv6/netfilter/ip6_tables.c
===================================================================
--- linux-2.6.8.nf.orig/net/ipv6/netfilter/ip6_tables.c	2004-09-30 14:07:51.000000000 +0200
+++ linux-2.6.8.nf/net/ipv6/netfilter/ip6_tables.c	2004-09-30 14:07:57.000000000 +0200
@@ -219,7 +219,7 @@
 		u_int16_t ptr;		/* Header offset in skb */
 		u_int16_t hdrlen;	/* Header */
 
-		ptr = IPV6_HDR_LEN;
+		ptr = ((char *) ipv6 - (char *) skb->data) + IPV6_HDR_LEN;
 
 		while (ip6t_ext_hdr(currenthdr)) {
 	                /* Is there enough space for the next ext header? */

-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 
