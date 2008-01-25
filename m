From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25][IPV4][FIB] fix fib_proc compilation error
Date: Fri, 25 Jan 2008 14:30:49 +0100
Message-ID: <4799E489.90008@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080201050701030808070901"
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:2936 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754300AbYAYNeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 08:34:09 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0PDY7QN217128
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 13:34:07 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0PDY7335087446
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 13:34:07 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0PDY4Wm031768
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 13:34:04 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080201050701030808070901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------080201050701030808070901
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

Index: net-2.6.25-fix/include/net/ip_fib.h
===================================================================
--- net-2.6.25-fix.orig/include/net/ip_fib.h
+++ net-2.6.25-fix/include/net/ip_fib.h
@@ -264,6 +264,16 @@ static inline void fib_res_put(struct fi
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

--------------080201050701030808070901--
