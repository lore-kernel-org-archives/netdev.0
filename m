From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 05/05]IPtablestng/UserSpace - patch extensions
Date: Mon, 27 Oct 2008 08:58:22 +0330 (IRST)
Message-ID: <20081027052822.2467FC64096@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use 'pktt_entry' instead of 'ipt_entry'.

also he creates new target named 'libipt_chain.c'. he is a helper target like 'standard' that provides the ability to use chains as target.

diff --git a/extensions/libipt_DNAT.c b/extensions/libipt_DNAT.c
index fed7611..e3cc2eb 100644
--- a/extensions/libipt_DNAT.c
+++ b/extensions/libipt_DNAT.c
@@ -143,9 +143,9 @@ static int DNAT_parse(int c, char **argv, int invert, unsigned int *flags,
 	struct ipt_natinfo *info = (void *)*target;
 	int portok;
 
-	if (entry->ip.proto == IPPROTO_TCP
-	    || entry->ip.proto == IPPROTO_UDP
-	    || entry->ip.proto == IPPROTO_ICMP)
+	if (entry->pkt_header.ip4.proto == IPPROTO_TCP
+	    || entry->pkt_header.ip4.proto == IPPROTO_UDP
+	    || entry->pkt_header.ip4.proto == IPPROTO_ICMP)
 		portok = 1;
 	else
 		portok = 0;
diff --git a/extensions/libipt_MASQUERADE.c b/extensions/libipt_MASQUERADE.c
index ea4f5cd..f3ec4d3 100644
--- a/extensions/libipt_MASQUERADE.c
+++ b/extensions/libipt_MASQUERADE.c
@@ -79,9 +79,9 @@ static int MASQUERADE_parse(int c, char **argv, int invert, unsigned int *flags,
 	struct ip_nat_multi_range *mr
 		= (struct ip_nat_multi_range *)(*target)->data;
 
-	if (entry->ip.proto == IPPROTO_TCP
-	    || entry->ip.proto == IPPROTO_UDP
-	    || entry->ip.proto == IPPROTO_ICMP)
+	if (entry->pkt_header.ip4.proto == IPPROTO_TCP
+	    || entry->pkt_header.ip4.proto == IPPROTO_UDP
+	    || entry->pkt_header.ip4.proto == IPPROTO_ICMP)
 		portok = 1;
 	else
 		portok = 0;
diff --git a/extensions/libipt_REDIRECT.c b/extensions/libipt_REDIRECT.c
index c03562b..9f373de 100644
--- a/extensions/libipt_REDIRECT.c
+++ b/extensions/libipt_REDIRECT.c
@@ -86,9 +86,9 @@ static int REDIRECT_parse(int c, char **argv, int invert, unsigned int *flags,
 		= (struct ip_nat_multi_range *)(*target)->data;
 	int portok;
 
-	if (entry->ip.proto == IPPROTO_TCP
-	    || entry->ip.proto == IPPROTO_UDP
-	    || entry->ip.proto == IPPROTO_ICMP)
+	if (entry->pkt_header.ip4.proto == IPPROTO_TCP
+	    || entry->pkt_header.ip4.proto == IPPROTO_UDP
+	    || entry->pkt_header.ip4.proto == IPPROTO_ICMP)
 		portok = 1;
 	else
 		portok = 0;
diff --git a/extensions/libipt_SNAT.c b/extensions/libipt_SNAT.c
index 11536c6..7881bc1 100644
--- a/extensions/libipt_SNAT.c
+++ b/extensions/libipt_SNAT.c
@@ -143,9 +143,9 @@ static int SNAT_parse(int c, char **argv, int invert, unsigned int *flags,
 	struct ipt_natinfo *info = (void *)*target;
 	int portok;
 
-	if (entry->ip.proto == IPPROTO_TCP
-	    || entry->ip.proto == IPPROTO_UDP
-	    || entry->ip.proto == IPPROTO_ICMP)
+	if (entry->pkt_header.ip4.proto == IPPROTO_TCP
+	    || entry->pkt_header.ip4.proto == IPPROTO_UDP
+	    || entry->pkt_header.ip4.proto == IPPROTO_ICMP)
 		portok = 1;
 	else
 		portok = 0;
diff --git a/extensions/libxt_chain.c b/extensions/libxt_chain.c
new file mode 100644
index 0000000..ffbc61e
--- /dev/null
+++ b/extensions/libxt_chain.c
@@ -0,0 +1,44 @@
+/* Shared library add-on to iptables for standard target support. */
+#include <stdio.h>
+#include <netdb.h>
+#include <string.h>
+#include <stdlib.h>
+#include <limits.h>
+#include <getopt.h>
+#include <xtables.h>
+
+/* Function which prints out usage message. */
+static void chain_help(void)
+{
+	printf(
+"chain target options:\n"
+"When using a chain as target\n");
+}
+
+/* Function which parses command options; returns true if it
+   ate an option */
+static int chain_parse(int c, char **argv, int invert, unsigned int *flags,
+                          const void *entry, struct xt_entry_target **target)
+{
+	return 0;
+}
+
+void chain_save(const void *ip,
+		const struct xt_entry_target *target){
+}
+
+static struct xtables_target standard_target = {
+	.family		= AF_UNSPEC,
+	.name		= "chain",
+	.version	= XTABLES_VERSION,
+	.size		= XT_ALIGN(sizeof(int)),
+	.userspacesize	= XT_ALIGN(sizeof(int)),
+	.help		= chain_help,
+	.parse		= chain_parse,
+	.save		= chain_save,
+};
+
+void _init(void)
+{
+	xtables_register_target(&standard_target);
+}
diff --git a/extensions/libxt_multiport.c b/extensions/libxt_multiport.c
index 413f178..de6a650 100644
--- a/extensions/libxt_multiport.c
+++ b/extensions/libxt_multiport.c
@@ -206,7 +206,7 @@ multiport_parse(int c, char **argv, int invert, unsigned int *flags,
 {
 	const struct ipt_entry *entry = e;
 	return __multiport_parse(c, argv, invert, flags, match,
-	       entry->ip.proto, entry->ip.invflags);
+	       entry->pkt_header.ip4.proto, entry->pkt_header.ip4.invflags);
 }
 
 static int
@@ -269,7 +269,7 @@ multiport_parse_v1(int c, char **argv, int invert, unsigned int *flags,
 {
 	const struct ipt_entry *entry = e;
 	return __multiport_parse_v1(c, argv, invert, flags, match,
-	       entry->ip.proto, entry->ip.invflags);
+	       entry->pkt_header.ip4.proto, entry->pkt_header.ip4.invflags);
 }
 
 static int

