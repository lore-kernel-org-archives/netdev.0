From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] filter: do not output bpf image address for
 security reason
Date: Fri, 17 May 2013 19:57:37 -0700
Message-ID: <1368845857.3301.148.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:37702 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758543Ab3ERC5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 22:57:39 -0400
Received: by mail-da0-f46.google.com with SMTP id e20so418822dak.19
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 19:57:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Do not leak starting address of BPF JIT code for non root users,
as it might help intruders to perform an attack.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
v2: use %pK as Ben suggestion

 include/linux/filter.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index c050dcc..56a6b7f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -58,10 +58,10 @@ extern void bpf_jit_free(struct sk_filter *fp);
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
 {
-	pr_err("flen=%u proglen=%u pass=%u image=%p\n",
+	pr_err("flen=%u proglen=%u pass=%u image=%pK\n",
 	       flen, proglen, pass, image);
 	if (image)
-		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
+		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
 			       16, 1, image, proglen, false);
 }
 #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
