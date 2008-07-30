From: akpm@linux-foundation.org
Subject: [patch 03/11] net: use the common ascii hex helpers
Date: Wed, 30 Jul 2008 12:37:35 -0700
Message-ID: <200807301937.m6UJbZ5d012431@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	harvey.harrison@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37688 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753241AbYG3Th7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:37:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/skfp/smt.c             |   13 ++++++-------
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    5 ++---
 2 files changed, 8 insertions(+), 10 deletions(-)

diff -puN drivers/net/skfp/smt.c~net-use-the-common-ascii-hex-helpers drivers/net/skfp/smt.c
--- a/drivers/net/skfp/smt.c~net-use-the-common-ascii-hex-helpers
+++ a/drivers/net/skfp/smt.c
@@ -19,6 +19,7 @@
 #include "h/smc.h"
 #include "h/smt_p.h"
 #include <linux/bitrev.h>
+#include <linux/kernel.h>
 
 #define KERNEL
 #include "h/smtstate.h"
@@ -1730,20 +1731,18 @@ void fddi_send_antc(struct s_smc *smc, s
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
 
diff -puN net/ipv4/netfilter/ipt_CLUSTERIP.c~net-use-the-common-ascii-hex-helpers net/ipv4/netfilter/ipt_CLUSTERIP.c
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c~net-use-the-common-ascii-hex-helpers
+++ a/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -475,11 +475,10 @@ static void arp_print(struct arp_payload
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
_
