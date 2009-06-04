From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/8] net/netfilter/ipvs/ip_vs_wrr.c: use lib/gcd.c
Date: Thu, 4 Jun 2009 16:16:21 +0200
Message-ID: <200906041616.22786.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "Linux-MIPS" <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	l
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

This patch removes the open-coded version of the
greatest common divider to use lib/gcd.c, the latter
also implementing the a < b case.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 79a6980..5b37675 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -113,6 +113,7 @@ config	IP_VS_RR
  
 config	IP_VS_WRR
         tristate "weighted round-robin scheduling" 
+	select GCD
 	---help---
 	  The weighted robin-robin scheduling algorithm directs network
 	  connections to different real servers based on server weights
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index f7d74ef..8701212 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/net.h>
+#include <linux/gcd.h>
 
 #include <net/ip_vs.h>
 
@@ -35,20 +36,6 @@ struct ip_vs_wrr_mark {
 };
 
 
-/*
- *    Get the gcd of server weights
- */
-static int gcd(int a, int b)
-{
-	int c;
-
-	while ((c = a % b)) {
-		a = b;
-		b = c;
-	}
-	return b;
-}
-
 static int ip_vs_wrr_gcd_weight(struct ip_vs_service *svc)
 {
 	struct ip_vs_dest *dest;
