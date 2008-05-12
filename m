From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 05/12] net: use the common ascii hex helpers
Date: Mon, 12 May 2008 12:05:38 -0700
Message-ID: <1210619138.24092.56.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:39389 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756845AbYELTFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 15:05:43 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1379070ywe.1
        for <netdev@vger.kernel.org>; Mon, 12 May 2008 12:05:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/skfp/smt.c             |   13 ++++++-------
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    5 ++---
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
index ffbfb1b..805383b 100644
--- a/drivers/net/skfp/smt.c
+++ b/drivers/net/skfp/smt.c
@@ -19,6 +19,7 @@
 #include "h/smc.h"
 #include "h/smt_p.h"
 #include <linux/bitrev.h>
+#include <linux/kernel.h>
 
 #define KERNEL
 #include "h/smtstate.h"
@@ -1730,20 +1731,18 @@ void fddi_send_antc(struct s_smc *smc, struct fddi_addr *dest)
 #endif
 
 #ifdef	DEBUG
-#define hextoasc(x)	"0123456789abcdef"[x]
-
 char *addr_to_string(struct fddi_addr *addr)
 {
 	int	i ;
 	static char	string[6*3] = "****" ;
 
 	for (i = 0 ; i < 6 ; i++) {
-		string[i*3] = hextoasc((addr->a[i]>>4)&0xf) ;
-		string[i*3+1] = hextoasc((addr->a[i])&0xf) ;
-		string[i*3+2] = ':' ;
+		string[i * 3] = hex_asc_hi(addr->a[i]);
+		string[i * 3 + 1] = hex_asc_lo(addr->a[i]);
+		string[i * 3 + 2] = ':';
 	}
-	string[5*3+2] = 0 ;
-	return(string) ;
+	string[5 * 3 + 2] = 0;
+	return(string);
 }
 #endif
 
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 1819ad7..fafe8eb 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -475,11 +475,10 @@ static void arp_print(struct arp_payload *payload)
 #define HBUFFERLEN 30
 	char hbuffer[HBUFFERLEN];
 	int j,k;
-	const char hexbuf[]= "0123456789abcdef";
 
 	for (k=0, j=0; k < HBUFFERLEN-3 && j < ETH_ALEN; j++) {
-		hbuffer[k++]=hexbuf[(payload->src_hw[j]>>4)&15];
-		hbuffer[k++]=hexbuf[payload->src_hw[j]&15];
+		hbuffer[k++] = hex_asc_hi(payload->src_hw[j]);
+		hbuffer[k++] = hex_asc_lo(payload->src_hw[j]);
 		hbuffer[k++]=':';
 	}
 	hbuffer[--k]='\0';
-- 
1.5.5.1.404.g981f6


