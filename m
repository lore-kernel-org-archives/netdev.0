From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: add SK_MEMINFO_DROPS display
Date: Thu, 21 Apr 2016 05:19:04 -0700
Message-ID: <1461241144.7627.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36160 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbcDUMTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 08:19:07 -0400
Received: by mail-pa0-f50.google.com with SMTP id er2so28753942pad.3
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 05:19:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

SK_MEMINFO_DROPS is added in linux-4.7 for TCP, UDP and SCTP

skmem will display the socket drop count using d prefix as in :

$ ss -tm src :22 | more
State      Recv-Q Send-Q Local Address:Port    Peer Address:Port                
ESTAB      0      52     10.246.7.151:ssh      172.20.10.101:50759                
	 skmem:(r0,rb8388608,t0,tb8388608,f1792,w2304,o0,bl0,d0)


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/sock_diag.h |    1 +
 misc/ss.c                 |    4 ++++
 2 files changed, 5 insertions(+)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index dafcb89..901231e 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -20,6 +20,7 @@ enum {
 	SK_MEMINFO_WMEM_QUEUED,
 	SK_MEMINFO_OPTMEM,
 	SK_MEMINFO_BACKLOG,
+	SK_MEMINFO_DROPS,
 
 	SK_MEMINFO_VARS,
 };
diff --git a/misc/ss.c b/misc/ss.c
index deefc96..3258584 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1905,6 +1905,10 @@ static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 		(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
 		printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
 
+	if (RTA_PAYLOAD(tb[attrtype]) >=
+		(SK_MEMINFO_DROPS + 1) * sizeof(__u32))
+		printf(",d%u", skmeminfo[SK_MEMINFO_DROPS]);
+
 	printf(")");
 }
 
