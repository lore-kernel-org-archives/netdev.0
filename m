From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6.26] [DCCP]: Use snmp_mib_{init,free}().
Date: Fri, 04 Apr 2008 00:16:11 +0900 (JST)
Message-ID: <20080404.001611.118922084.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60299 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756717AbYDCPOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 11:14:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e3f5d37..d534cdf 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1010,33 +1010,14 @@ void dccp_shutdown(struct sock *sk, int how)
 
 EXPORT_SYMBOL_GPL(dccp_shutdown);
 
-static int __init dccp_mib_init(void)
+static inline int dccp_mib_init(void)
 {
-	int rc = -ENOMEM;
-
-	dccp_statistics[0] = alloc_percpu(struct dccp_mib);
-	if (dccp_statistics[0] == NULL)
-		goto out;
-
-	dccp_statistics[1] = alloc_percpu(struct dccp_mib);
-	if (dccp_statistics[1] == NULL)
-		goto out_free_one;
-
-	rc = 0;
-out:
-	return rc;
-out_free_one:
-	free_percpu(dccp_statistics[0]);
-	dccp_statistics[0] = NULL;
-	goto out;
-
+	return snmp_mib_init((void**)dccp_statistics, sizeof(struct dccp_mib));
 }
 
-static void dccp_mib_exit(void)
+static inline void dccp_mib_exit(void)
 {
-	free_percpu(dccp_statistics[0]);
-	free_percpu(dccp_statistics[1]);
-	dccp_statistics[0] = dccp_statistics[1] = NULL;
+	snmp_mib_free((void**)dccp_statistics);
 }
 
 static int thash_entries;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
