From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6.26] [SCTP]: Use snmp_mib_{init,free}().
Date: Fri, 04 Apr 2008 00:16:14 +0900 (JST)
Message-ID: <20080404.001614.44373630.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60304 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758092AbYDCPOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 11:14:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index ad0a406..225e260 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -972,24 +972,14 @@ int sctp_register_pf(struct sctp_pf *pf, sa_family_t family)
 	return 1;
 }
 
-static int __init init_sctp_mibs(void)
+static inline int init_sctp_mibs(void)
 {
-	sctp_statistics[0] = alloc_percpu(struct sctp_mib);
-	if (!sctp_statistics[0])
-		return -ENOMEM;
-	sctp_statistics[1] = alloc_percpu(struct sctp_mib);
-	if (!sctp_statistics[1]) {
-		free_percpu(sctp_statistics[0]);
-		return -ENOMEM;
-	}
-	return 0;
-
+	return snmp_mib_init((void**)sctp_statistics, sizeof(struct sctp_mib));
 }
 
-static void cleanup_sctp_mibs(void)
+static inline void cleanup_sctp_mibs(void)
 {
-	free_percpu(sctp_statistics[0]);
-	free_percpu(sctp_statistics[1]);
+	snmp_mib_free((void**)sctp_statistics);
 }
 
 /* Initialize the universe into something sensible.  */

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
