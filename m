From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] filter: do not output bpf image address for
 security reason
Date: Fri, 17 May 2013 16:31:39 -0700
Message-ID: <1368833499.3301.126.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:33024 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab3EQXbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 19:31:41 -0400
Received: by mail-pb0-f53.google.com with SMTP id un1so3712961pbc.40
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 16:31:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Do not leak starting address of BPF JIT code, as it might help
intruders to perform an attack.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/filter.h |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index c050dcc..08cda1c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -58,10 +58,11 @@ extern void bpf_jit_free(struct sk_filter *fp);
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
 {
-	pr_err("flen=%u proglen=%u pass=%u image=%p\n",
-	       flen, proglen, pass, image);
+	/* Do not output address (image) for security reason */
+	pr_err("flen=%u proglen=%u pass=%u image=10\n",
+	       flen, proglen, pass);
 	if (image)
-		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
+		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
 			       16, 1, image, proglen, false);
 }
 #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
