From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 1/2] iptables: extensions: unnecessary cast on void pointer
Date: Sun,  2 Apr 2017 19:21:03 +0530
Message-ID: <20170402135104.24342-1-arushisinghal19971997@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36526 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbdDBNvO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 09:51:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following Coccinelle script was used to detect this:
@r@
expression x;
void* e;
type T;
identifier f;
@@
(
  *((T *)e)
|
  ((T *)x)[...]
|
  ((T*)x)->f
|

- (T*)
  e
)

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 extensions/libarpt_mangle.c  |  2 +-
 extensions/libip6t_rt.c      |  2 +-
 extensions/libxt_hashlimit.c |  2 +-
 extensions/libxt_mangle.c    | 16 ++++++++--------
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/extensions/libarpt_mangle.c b/extensions/libarpt_mangle.c
index 358b35d..8d81cb5 100644
--- a/extensions/libarpt_mangle.c
+++ b/extensions/libarpt_mangle.c
@@ -55,7 +55,7 @@ arpmangle_parse(int c, char **argv, int invert, unsigned int *flags,
 	struct arpt_mangle *mangle = (struct arpt_mangle *)(*target)->data;
 	struct in_addr *ipaddr, mask;
 	struct ether_addr *macaddr;
-	const struct arpt_entry *e = (const struct arpt_entry *)entry;
+	const struct arpt_entry *e = entry;
 	unsigned int nr;
 	int ret = 1;
 
diff --git a/extensions/libip6t_rt.c b/extensions/libip6t_rt.c
index 3cb3b24..2e0aeb4 100644
--- a/extensions/libip6t_rt.c
+++ b/extensions/libip6t_rt.c
@@ -64,7 +64,7 @@ numeric_to_addr(const char *num)
 #endif
 	xtables_error(PARAMETER_PROBLEM, "bad address: %s", num);
 
-	return (struct in6_addr *)NULL;
+	return NULL;
 }
 
 
diff --git a/extensions/libxt_hashlimit.c b/extensions/libxt_hashlimit.c
index 52fc4fa..bd72970 100644
--- a/extensions/libxt_hashlimit.c
+++ b/extensions/libxt_hashlimit.c
@@ -186,7 +186,7 @@ static int
 cfg_copy(struct hashlimit_cfg2 *to, const void *from, int revision)
 {
 	if (revision == 1) {
-		struct hashlimit_cfg1 *cfg = (struct hashlimit_cfg1 *)from;
+		struct hashlimit_cfg1 *cfg = from;
 
 		to->mode = cfg->mode;
 		to->avg = cfg->avg;
diff --git a/extensions/libxt_mangle.c b/extensions/libxt_mangle.c
index 360742b..012037b 100644
--- a/extensions/libxt_mangle.c
+++ b/extensions/libxt_mangle.c
@@ -59,12 +59,12 @@ static struct in_addr *network_to_addr(const char *name)
 
 	if ((net = getnetbyname(name)) != NULL) {
 		if (net->n_addrtype != AF_INET)
-			return (struct in_addr *) NULL;
+			return NULL;
 		addr.s_addr = htonl((unsigned long) net->n_net);
 		return &addr;
 	}
 
-	return (struct in_addr *) NULL;
+	return NULL;
 }
 
 static void inaddrcpy(struct in_addr *dst, struct in_addr *src)
@@ -101,7 +101,7 @@ static struct in_addr *host_to_addr(const char *name, unsigned int *naddr)
 		return addr;
 	}
 
-	return (struct in_addr *) NULL;
+	return NULL;
 }
 
 static int string_to_number(const char *s, unsigned int min,
@@ -139,11 +139,11 @@ static struct in_addr *dotted_to_addr(const char *dotted)
 	p = buf;
 	for (i = 0; i < 3; i++) {
 		if ((q = strchr(p, '.')) == NULL)
-			return (struct in_addr *) NULL;
+			return NULL;
 
 		*q = '\0';
 		if (string_to_number(p, 0, 255, &onebyte) == -1)
-			return (struct in_addr *) NULL;
+			return NULL;
 
 		addrp[i] = (unsigned char) onebyte;
 		p = q + 1;
@@ -151,7 +151,7 @@ static struct in_addr *dotted_to_addr(const char *dotted)
 
 	/* we've checked 3 bytes, now we check the last one */
 	if (string_to_number(p, 0, 255, &onebyte) == -1)
-		return (struct in_addr *) NULL;
+		return NULL;
 
 	addrp[3] = (unsigned char) onebyte;
 
@@ -300,7 +300,7 @@ static char *addr_to_host(const struct in_addr *addr)
 				  sizeof(struct in_addr), AF_INET)) != NULL)
 		return (char *) host->h_name;
 
-	return (char *) NULL;
+	return NULL;
 }
 
 static char *addr_to_network(const struct in_addr *addr)
@@ -310,7 +310,7 @@ static char *addr_to_network(const struct in_addr *addr)
 	if ((net = getnetbyaddr((long) ntohl(addr->s_addr), AF_INET)) != NULL)
 		return (char *) net->n_name;
 
-	return (char *) NULL;
+	return NULL;
 }
 
 static char *addr_to_anyname(const struct in_addr *addr)
-- 
2.11.0
