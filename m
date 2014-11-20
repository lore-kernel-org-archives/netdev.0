From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] filter: add bpf_optimize_div()
Date: Thu, 20 Nov 2014 22:42:31 +0300
Message-ID: <1416512551-22252-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
	Alexei Starovoitov <ast@plumgrid.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:57819 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbaKTUKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 15:10:31 -0500
Received: by mail-lb0-f175.google.com with SMTP id u10so7494lbd.34
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 12:10:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

optimize_div() found in  mips bpf jit is really usefull
for other arches. So let's put it in filter.h

CC: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 include/linux/filter.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index ca95abd..b385637 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -414,6 +414,17 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
 			       16, 1, image, proglen, false);
 }
+
+static inline int bpf_optimize_div(u32 *k)
+{
+	/* power of 2 divides can be implemented with right shift */
+	if (!(*k & (*k-1))) {
+		*k = ilog2(*k);
+		return 1;
+	}
+
+	return 0;
+}
 #else
 static inline void bpf_jit_compile(struct bpf_prog *fp)
 {
-- 
2.1.0
