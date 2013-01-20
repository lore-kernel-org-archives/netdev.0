From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 2/5] ipv6: Introduce ipv6_addr_is_solict_mult() to
 check Solicited Node Multicast Addresses.
Date: Mon, 21 Jan 2013 02:39:00 +0900
Message-ID: <50FC2BB4.9020801@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48881 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752440Ab3ATRjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 12:39:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/addrconf.h |    8 ++++++++
 net/ipv6/ndisc.c       |    6 +-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index c6a4421..3a3eeb4 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -305,6 +305,14 @@ static inline bool ipv6_addr_is_isatap(const struct in6_addr *addr)
 	return (addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE);
 }
 
+static inline bool ipv6_addr_is_solict_mult(const struct in6_addr *addr)
+{
+	return (addr->s6_addr32[0] == htonl(0xff020000) &&
+		addr->s6_addr32[1] == htonl(0x00000000) &&
+		addr->s6_addr32[2] == htonl(0x00000001) &&
+		addr->s6_addr[12] == 0xff);
+}
+
 #ifdef CONFIG_PROC_FS
 extern int if6_proc_init(void);
 extern void if6_proc_exit(void);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 350f860..903191a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -685,11 +685,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	 * RFC2461 7.1.1:
 	 * DAD has to be destined for solicited node multicast address.
 	 */
-	if (dad &&
-	    !(daddr->s6_addr32[0] == htonl(0xff020000) &&
-	      daddr->s6_addr32[1] == htonl(0x00000000) &&
-	      daddr->s6_addr32[2] == htonl(0x00000001) &&
-	      daddr->s6_addr [12] == 0xff )) {
+	if (dad && !ipv6_addr_is_solict_mult(daddr)) {
 		ND_PRINTK(2, warn, "NS: bad DAD packet (wrong destination)\n");
 		return;
 	}
-- 
1.7.9.5
