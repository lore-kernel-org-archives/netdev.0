From: Patrick McHardy <kaber@trash.net>
Subject: ipvs 01/04: ip_vs_wrr.c: use lib/gcd.c
Date: Fri,  8 Jan 2010 17:42:09 +0100 (MET)
Message-ID: <20100108164206.28066.65576.sendpatchset@x2.localnet>
References: <20100108164204.28066.44430.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100108164204.28066.44430.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit ae24e578de02b87cce3dc59248c29b2ecb071e9e
Author: Florian Fainelli <florian@openwrt.org>
Date:   Tue Dec 22 09:42:06 2009 +0100

    ipvs: ip_vs_wrr.c: use lib/gcd.c
    
    Remove the private version of the greatest common divider to use
    lib/gcd.c, the latter also implementing the a < b case.
    
    [akpm@linux-foundation.org: repair neighboring whitespace because the diff looked odd]
    Signed-off-by: Florian Fainelli <florian@openwrt.org>
    Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>
    Cc: Takashi Iwai <tiwai@suse.de>
    Acked-by: Simon Horman <horms@verge.net.au>
    Cc: Julius Volz <juliusv@google.com>
    Cc: David S. Miller <davem@davemloft.net>
    Cc: Patrick McHardy <kaber@trash.net>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 79a6980..f2d7623 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -112,7 +112,8 @@ config	IP_VS_RR
 	  module, choose M here. If unsure, say N.
  
 config	IP_VS_WRR
-        tristate "weighted round-robin scheduling" 
+	tristate "weighted round-robin scheduling"
+	select GCD
 	---help---
 	  The weighted robin-robin scheduling algorithm directs network
 	  connections to different real servers based on server weights
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 6182e8e..3c115fc 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -24,6 +24,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/net.h>
+#include <linux/gcd.h>
 
 #include <net/ip_vs.h>
 
@@ -38,20 +39,6 @@ struct ip_vs_wrr_mark {
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
