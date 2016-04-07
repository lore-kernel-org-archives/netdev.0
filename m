From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH ipoute2] iplink: display number of rx/tx queues
Date: Thu, 07 Apr 2016 16:11:39 -0700
Message-ID: <1460070699.6473.428.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36569 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbcDGXLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 19:11:41 -0400
Received: by mail-pf0-f176.google.com with SMTP id e128so64119822pfe.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 16:11:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We can set the attributes, so would be nice to display them when
provided by the kernel.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3998d8c..f7bd1c7 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -894,6 +894,12 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (do_link && tb[IFLA_AF_SPEC] && show_details)
 		print_af_spec(fp, tb[IFLA_AF_SPEC]);
 
+	if (tb[IFLA_NUM_TX_QUEUES] && show_details)
+		fprintf(fp, "numtxqueues %u ", rta_getattr_u32(tb[IFLA_NUM_TX_QUEUES]));
+
+	if (tb[IFLA_NUM_RX_QUEUES] && show_details)
+		fprintf(fp, "numrxqueues %u ", rta_getattr_u32(tb[IFLA_NUM_RX_QUEUES]));
+
 	if ((do_link || show_details) && tb[IFLA_IFALIAS]) {
 		fprintf(fp, "%s    alias %s", _SL_,
 			rta_getattr_str(tb[IFLA_IFALIAS]));
