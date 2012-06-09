From: ppluzhnikov@google.com (Paul Pluzhnikov)
Subject: [PATCH torvalds/linux.git] Make linux/tcp.h C++ friendly (trivial)
Date: Sat,  9 Jun 2012 07:53:03 -0700 (PDT)
Message-ID: <20120609145303.3094919060E@elbrus2.mtv.corp.google.com>
Cc: ppluzhnikov@google.com, Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f74.google.com ([74.125.82.74]:61697 "EHLO
	mail-wg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab2FIOxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 10:53:06 -0400
Received: by wgbdt11 with SMTP id dt11so152400wgb.1
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2012 07:53:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Pluzhnikov <ppluzhnikov@google.com>

I originally sent this patch to <trivial@kernel.org>, but Jiri Kosina did
not feel that this is fully appropriate for the trivial tree.


Using linux/tcp.h from C++ results in:

cat t.cc
#include <linux/tcp.h>
int main() { }

g++ -c t.cc

In file included from t.cc:1:
/usr/include/linux/tcp.h:72: error: '__u32 __fswab32(__u32)' cannot appear in a constant-expression
/usr/include/linux/tcp.h:72: error: a function call cannot appear in a constant-expression
...

Attached trivial patch fixes this problem.

Tested:
- the t.cc above compiles with g++ and
- the following program generates the same output before/after
  the patch:

#include <linux/tcp.h>
#include <stdio.h>

int main ()
{
#define P(a) printf("%s: %08x\n", #a, (int)a)
 P(TCP_FLAG_CWR);
 P(TCP_FLAG_ECE);
 P(TCP_FLAG_URG);
 P(TCP_FLAG_ACK);
 P(TCP_FLAG_PSH);
 P(TCP_FLAG_RST);
 P(TCP_FLAG_SYN);
 P(TCP_FLAG_FIN);
 P(TCP_RESERVED_BITS);
 P(TCP_DATA_OFFSET);
#undef P
 return 0;
}


Thanks,

P.S. Google has blanket copyright assignment to FSF.

Signed-off-by: Paul Pluzhnikov <ppluzhnikov@google.com>
---

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4c5b632..5f359db 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -69,16 +69,16 @@ union tcp_word_hdr {
 #define tcp_flag_word(tp) ( ((union tcp_word_hdr *)(tp))->words [3]) 
 
 enum { 
-	TCP_FLAG_CWR = __cpu_to_be32(0x00800000),
-	TCP_FLAG_ECE = __cpu_to_be32(0x00400000),
-	TCP_FLAG_URG = __cpu_to_be32(0x00200000),
-	TCP_FLAG_ACK = __cpu_to_be32(0x00100000),
-	TCP_FLAG_PSH = __cpu_to_be32(0x00080000),
-	TCP_FLAG_RST = __cpu_to_be32(0x00040000),
-	TCP_FLAG_SYN = __cpu_to_be32(0x00020000),
-	TCP_FLAG_FIN = __cpu_to_be32(0x00010000),
-	TCP_RESERVED_BITS = __cpu_to_be32(0x0F000000),
-	TCP_DATA_OFFSET = __cpu_to_be32(0xF0000000)
+	TCP_FLAG_CWR = __constant_cpu_to_be32(0x00800000),
+	TCP_FLAG_ECE = __constant_cpu_to_be32(0x00400000),
+	TCP_FLAG_URG = __constant_cpu_to_be32(0x00200000),
+	TCP_FLAG_ACK = __constant_cpu_to_be32(0x00100000),
+	TCP_FLAG_PSH = __constant_cpu_to_be32(0x00080000),
+	TCP_FLAG_RST = __constant_cpu_to_be32(0x00040000),
+	TCP_FLAG_SYN = __constant_cpu_to_be32(0x00020000),
+	TCP_FLAG_FIN = __constant_cpu_to_be32(0x00010000),
+	TCP_RESERVED_BITS = __constant_cpu_to_be32(0x0F000000),
+	TCP_DATA_OFFSET = __constant_cpu_to_be32(0xF0000000)
 }; 
 
 /*
