From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 2/2] iptables: iptables: unnecessary cast on void pointer
Date: Sun,  2 Apr 2017 19:21:04 +0530
Message-ID: <20170402135104.24342-2-arushisinghal19971997@gmail.com>
References: <20170402135104.24342-1-arushisinghal19971997@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170402135104.24342-1-arushisinghal19971997@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 iptables/nft-arp.c     |  4 ++--
 iptables/xtables-arp.c | 12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/iptables/nft-arp.c b/iptables/nft-arp.c
index 0e13b8c..335963c 100644
--- a/iptables/nft-arp.c
+++ b/iptables/nft-arp.c
@@ -62,7 +62,7 @@ addr_to_host(const struct in_addr *addr)
 					sizeof(struct in_addr), AF_INET)) != NULL)
 		return (char *) host->h_name;
 
-	return (char *) NULL;
+	return NULL;
 }
 
 static char *
@@ -73,7 +73,7 @@ addr_to_network(const struct in_addr *addr)
 	if ((net = getnetbyaddr((long) ntohl(addr->s_addr), AF_INET)) != NULL)
 		return (char *) net->n_name;
 
-	return (char *) NULL;
+	return NULL;
 }
 
 static char *
diff --git a/iptables/xtables-arp.c b/iptables/xtables-arp.c
index 85feb48..d346d3e 100644
--- a/iptables/xtables-arp.c
+++ b/iptables/xtables-arp.c
@@ -361,11 +361,11 @@ dotted_to_addr(const char *dotted)
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
@@ -373,7 +373,7 @@ dotted_to_addr(const char *dotted)
 
 	/* we've checked 3 bytes, now we check the last one */
 	if (string_to_number(p, 0, 255, &onebyte) == -1)
-		return (struct in_addr *) NULL;
+		return NULL;
 
 	addrp[3] = (unsigned char) onebyte;
 
@@ -388,12 +388,12 @@ network_to_addr(const char *name)
 
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
 
 static void
@@ -614,7 +614,7 @@ host_to_addr(const char *name, unsigned int *naddr)
 		return addr;
 	}
 
-	return (struct in_addr *) NULL;
+	return NULL;
 }
 
 /*
-- 
2.11.0

