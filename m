From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/4] bpf: also show process name/pid in bpf_jit_dump
Date: Thu, 30 Jul 2015 12:42:49 +0200
Message-ID: <4e1ef7ef805135f77136175858436eeea85ae9e7.1438250937.git.daniel@iogearbox.net>
References: <cover.1438250937.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, holzheu@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52564 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbbG3Kmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 06:42:55 -0400
In-Reply-To: <cover.1438250937.git.daniel@iogearbox.net>
In-Reply-To: <cover.1438250937.git.daniel@iogearbox.net>
References: <cover.1438250937.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can be useful for testing to see the actual process/pid who is loading
a given filter. I was running some BPF test program and noticed unusual
filter loads from time to time, triggered by some other application in the
background. bpf_jit_disasm is still working after this change.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 6b02549..fa2cab9 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -12,6 +12,7 @@
 #include <linux/linkage.h>
 #include <linux/printk.h>
 #include <linux/workqueue.h>
+#include <linux/sched.h>
 
 #include <asm/cacheflush.h>
 
@@ -438,8 +439,9 @@ void bpf_jit_free(struct bpf_prog *fp);
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
 {
-	pr_err("flen=%u proglen=%u pass=%u image=%pK\n",
-	       flen, proglen, pass, image);
+	pr_err("flen=%u proglen=%u pass=%u image=%pK from=%s pid=%d\n", flen,
+	       proglen, pass, image, current->comm, task_pid_nr(current));
+
 	if (image)
 		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
 			       16, 1, image, proglen, false);
-- 
1.9.3
