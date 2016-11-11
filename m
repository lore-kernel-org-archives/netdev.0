From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 08/18] ss: Turn generic_proc_open() wrappers into macros
Date: Fri, 11 Nov 2016 14:10:04 +0100
Message-ID: <20161111131014.21865-9-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51015 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756485AbcKKNK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:10:57 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 89 ++++++++++++++-------------------------------------------------
 1 file changed, 19 insertions(+), 70 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 8e021731cf71c..e9fecd39a8493 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -306,76 +306,25 @@ static FILE *generic_proc_open(const char *env, const char *name)
 
 	return fopen(p, "r");
 }
-
-static FILE *net_tcp_open(void)
-{
-	return generic_proc_open("PROC_NET_TCP", "net/tcp");
-}
-
-static FILE *net_tcp6_open(void)
-{
-	return generic_proc_open("PROC_NET_TCP6", "net/tcp6");
-}
-
-static FILE *net_udp_open(void)
-{
-	return generic_proc_open("PROC_NET_UDP", "net/udp");
-}
-
-static FILE *net_udp6_open(void)
-{
-	return generic_proc_open("PROC_NET_UDP6", "net/udp6");
-}
-
-static FILE *net_raw_open(void)
-{
-	return generic_proc_open("PROC_NET_RAW", "net/raw");
-}
-
-static FILE *net_raw6_open(void)
-{
-	return generic_proc_open("PROC_NET_RAW6", "net/raw6");
-}
-
-static FILE *net_unix_open(void)
-{
-	return generic_proc_open("PROC_NET_UNIX", "net/unix");
-}
-
-static FILE *net_packet_open(void)
-{
-	return generic_proc_open("PROC_NET_PACKET", "net/packet");
-}
-
-static FILE *net_netlink_open(void)
-{
-	return generic_proc_open("PROC_NET_NETLINK", "net/netlink");
-}
-
-static FILE *slabinfo_open(void)
-{
-	return generic_proc_open("PROC_SLABINFO", "slabinfo");
-}
-
-static FILE *net_sockstat_open(void)
-{
-	return generic_proc_open("PROC_NET_SOCKSTAT", "net/sockstat");
-}
-
-static FILE *net_sockstat6_open(void)
-{
-	return generic_proc_open("PROC_NET_SOCKSTAT6", "net/sockstat6");
-}
-
-static FILE *net_snmp_open(void)
-{
-	return generic_proc_open("PROC_NET_SNMP", "net/snmp");
-}
-
-static FILE *ephemeral_ports_open(void)
-{
-	return generic_proc_open("PROC_IP_LOCAL_PORT_RANGE", "sys/net/ipv4/ip_local_port_range");
-}
+#define net_tcp_open()		generic_proc_open("PROC_NET_TCP", "net/tcp")
+#define net_tcp6_open()		generic_proc_open("PROC_NET_TCP6", "net/tcp6")
+#define net_udp_open()		generic_proc_open("PROC_NET_UDP", "net/udp")
+#define net_udp6_open()		generic_proc_open("PROC_NET_UDP6", "net/udp6")
+#define net_raw_open()		generic_proc_open("PROC_NET_RAW", "net/raw")
+#define net_raw6_open()		generic_proc_open("PROC_NET_RAW6", "net/raw6")
+#define net_unix_open()		generic_proc_open("PROC_NET_UNIX", "net/unix")
+#define net_packet_open()	generic_proc_open("PROC_NET_PACKET", \
+							"net/packet")
+#define net_netlink_open()	generic_proc_open("PROC_NET_NETLINK", \
+							"net/netlink")
+#define slabinfo_open()		generic_proc_open("PROC_SLABINFO", "slabinfo")
+#define net_sockstat_open()	generic_proc_open("PROC_NET_SOCKSTAT", \
+							"net/sockstat")
+#define net_sockstat6_open()	generic_proc_open("PROC_NET_SOCKSTAT6", \
+							"net/sockstat6")
+#define net_snmp_open()		generic_proc_open("PROC_NET_SNMP", "net/snmp")
+#define ephemeral_ports_open()	generic_proc_open("PROC_IP_LOCAL_PORT_RANGE", \
+					"sys/net/ipv4/ip_local_port_range")
 
 struct user_ent {
 	struct user_ent	*next;
-- 
2.10.0
