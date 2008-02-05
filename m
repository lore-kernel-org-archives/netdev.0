From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [FIB] fix fib_proc compilation error
Date: Tue, 05 Feb 2008 10:11:54 +0100
Message-ID: <47A8285A.7040205@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030900060404030204020400"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:18309 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbYBEJRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 04:17:12 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m159HB8x200072
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 09:17:11 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m159HBVM5095662
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 09:17:11 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m159H7V3010784
	for <netdev@vger.kernel.org>; Tue, 5 Feb 2008 09:17:07 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030900060404030204020400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------030900060404030204020400
Content-Type: text/x-patch;
 name="fix-fib-frontend-compilation-error.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-fib-frontend-compilation-error.patch"

Subject: fix fib_proc compilation error
From: Daniel Lezcano <dlezcano@fr.ibm.com>

Fix fib_proc_[init|exit] definition when CONFIG_PROCFS=no

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ip_fib.h |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: net-2.6/include/net/ip_fib.h
===================================================================
--- net-2.6.orig/include/net/ip_fib.h
+++ net-2.6/include/net/ip_fib.h
@@ -266,6 +266,16 @@ static inline void fib_res_put(struct fi
 #ifdef CONFIG_PROC_FS
 extern int __net_init  fib_proc_init(struct net *net);
 extern void __net_exit fib_proc_exit(struct net *net);
+#else
+static inline int fib_proc_init(struct net *net)
+{
+	return 0;
+}
+
+static inline void fib_proc_exit(struct net *net)
+{
+	return ;
+}
 #endif
 
 #endif  /* _NET_FIB_H */

--------------030900060404030204020400--
