From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/8 v3] sparc: csum_add for Sparc
Date: Tue, 29 Apr 2014 09:18:24 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404290900210.9313@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:62838 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757871AbaD2QS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 12:18:27 -0400
Received: by mail-oa0-f74.google.com with SMTP id i7so88673oag.3
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 09:18:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From David Miller, add arch support for csum_add for 32 and 64 bit
versions.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 arch/sparc/include/asm/checksum_32.h | 12 ++++++++++++
 arch/sparc/include/asm/checksum_64.h | 12 ++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/arch/sparc/include/asm/checksum_32.h b/arch/sparc/include/asm/checksum_32.h
index bdbda14..04471dc 100644
--- a/arch/sparc/include/asm/checksum_32.h
+++ b/arch/sparc/include/asm/checksum_32.h
@@ -238,4 +238,16 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 	return csum_fold(csum_partial(buff, len, 0));
 }
 
+#define HAVE_ARCH_CSUM_ADD
+static inline __wsum csum_add(__wsum csum, __wsum addend)
+{
+	__asm__ __volatile__(
+		"addcc   %0, %1, %0\n"
+		"addx    %0, %%g0, %0"
+		: "=r" (csum)
+		: "r" (addend), "0" (csum));
+
+	return csum;
+}
+
 #endif /* !(__SPARC_CHECKSUM_H) */
diff --git a/arch/sparc/include/asm/checksum_64.h b/arch/sparc/include/asm/checksum_64.h
index 019b961..2ff81ae 100644
--- a/arch/sparc/include/asm/checksum_64.h
+++ b/arch/sparc/include/asm/checksum_64.h
@@ -164,4 +164,16 @@ static inline __sum16 ip_compute_csum(const void *buff, int len)
 	return csum_fold(csum_partial(buff, len, 0));
 }
 
+#define HAVE_ARCH_CSUM_ADD
+static inline __wsum csum_add(__wsum csum, __wsum addend)
+{
+	__asm__ __volatile__(
+		"addcc   %0, %1, %0\n"
+		"addx    %0, %%g0, %0"
+		: "=r" (csum)
+		: "r" (addend), "0" (csum));
+
+	return csum;
+}
+
 #endif /* !(__SPARC64_CHECKSUM_H) */
-- 
1.9.1.423.g4596e3a
